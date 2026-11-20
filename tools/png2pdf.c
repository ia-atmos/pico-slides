// png2pdf: writes a PDF with one page per image.
//
//   png2pdf <out.pdf> <image> ...
//
// Each page has the proportion of its image and is 960 points wide (a
// wide slide of 13.33in). The pixels are kept as they are, compressed
// with no loss, and any transparency is dropped.
//
// Build (see ../setup.sh):
//   cc -O2 png2pdf.c -o png2pdf $(sdl2-config --cflags --libs) -lSDL2_image -lz

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>
#include <SDL.h>
#include <SDL_image.h>

#define PAGE_W 960.0

static void die (const char* msg, const char* arg) {
    fprintf(stderr, "png2pdf : %s%s%s\n", msg, arg ? " : " : "", arg ? arg : "");
    exit(1);
}

int main (int argc, char** argv) {
    if (argc < 3) {
        die("usage: png2pdf <out.pdf> <image> ...", NULL);
    }
    int n = argc - 2;

    FILE* out = fopen(argv[1], "wb");
    if (out == NULL) {
        die("cannot write", argv[1]);
    }

    // objects: 1 catalog, 2 pages, then 3 per page (page, contents, image)
    int nobjs = 2 + 3*n;
    long* offs = calloc(nobjs+1, sizeof(long));
    if (offs == NULL) {
        die("out of memory", NULL);
    }

    fprintf(out, "%%PDF-1.4\n%%\xE2\xE3\xCF\xD3\n");

    offs[1] = ftell(out);
    fprintf(out, "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");

    offs[2] = ftell(out);
    fprintf(out, "2 0 obj\n<< /Type /Pages /Count %d /Kids [", n);
    for (int i=0; i<n; i++) {
        fprintf(out, " %d 0 R", 3 + 3*i);
    }
    fprintf(out, " ] >>\nendobj\n");

    for (int i=0; i<n; i++) {
        const char* path = argv[2+i];
        SDL_Surface* raw = IMG_Load(path);
        if (raw == NULL) {
            die("cannot read", path);
        }
        SDL_Surface* img = SDL_ConvertSurfaceFormat(raw, SDL_PIXELFORMAT_RGB24, 0);
        SDL_FreeSurface(raw);
        if (img == NULL) {
            die("cannot convert", path);
        }
        int w = img->w;
        int h = img->h;

        // the rows with no padding
        unsigned long len = (unsigned long)w * h * 3;
        unsigned char* rgb = malloc(len);
        if (rgb == NULL) {
            die("out of memory", path);
        }
        for (int y=0; y<h; y++) {
            memcpy(rgb + (size_t)y*w*3, (unsigned char*)img->pixels + (size_t)y*img->pitch, (size_t)w*3);
        }
        SDL_FreeSurface(img);

        uLongf zlen = compressBound(len);
        unsigned char* z = malloc(zlen);
        if (z == NULL) {
            die("out of memory", path);
        }
        if (compress2(z, &zlen, rgb, len, 9) != Z_OK) {
            die("cannot compress", path);
        }
        free(rgb);

        int page = 3 + 3*i;
        double pw = PAGE_W;
        double ph = PAGE_W * h / w;

        offs[page] = ftell(out);
        fprintf(out,
            "%d 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.2f %.2f]"
            " /Resources << /XObject << /Im %d 0 R >> >> /Contents %d 0 R >>\nendobj\n",
            page, pw, ph, page+2, page+1);

        char cmd[128];
        int clen = snprintf(cmd, sizeof(cmd), "q %.2f 0 0 %.2f 0 0 cm /Im Do Q\n", pw, ph);
        offs[page+1] = ftell(out);
        fprintf(out, "%d 0 obj\n<< /Length %d >>\nstream\n%sendstream\nendobj\n",
            page+1, clen, cmd);

        offs[page+2] = ftell(out);
        fprintf(out,
            "%d 0 obj\n<< /Type /XObject /Subtype /Image /Width %d /Height %d"
            " /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode"
            " /Length %lu >>\nstream\n",
            page+2, w, h, (unsigned long)zlen);
        fwrite(z, 1, zlen, out);
        fprintf(out, "\nendstream\nendobj\n");
        free(z);
    }

    long xref = ftell(out);
    fprintf(out, "xref\n0 %d\n0000000000 65535 f \n", nobjs+1);
    for (int i=1; i<=nobjs; i++) {
        fprintf(out, "%010ld 00000 n \n", offs[i]);
    }
    fprintf(out, "trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%ld\n%%%%EOF\n",
        nobjs+1, xref);

    if (fclose(out) != 0) {
        die("cannot write", argv[1]);
    }
    free(offs);
    return 0;
}
