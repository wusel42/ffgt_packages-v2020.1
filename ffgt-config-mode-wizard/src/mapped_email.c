// SPDX-License-Identifier: BSD-2-Clause
// SPDX-FileCopyrightText: 2026 Kai 'wusel' Siering <wusel+src@uu.org>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int find_index(const char *str, char c) {
    const char *p = strchr(str, c);
    if (p) {
        return p - str;
    }
    return -1;
}

int main(int argc, char *argv[]) {
    const char *lower = "qmvzjypkhtxanrslfgeuicwobd";
    const char *upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const char *rot13 = "zabqkiwjnsdmhutflcorygpevx";
    const char *ROT13 = "NOPQRSTUVWXYZABCDEFGHIJKLM";
    const char *speci = "-.@+=_/*0123456789!#$&?^{|}~";
    const char *spe13 = "=_/*-.@+!#$&?^{|}~0123456789";
    const char *suffix = "@contacts.4830.org";

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <string>\n", argv[0]);
        return 1;
    }

    if(strlen(argv[1]) < 1) {
        return 0;
    }

    char *input = strdup(argv[1]);
    if (!input) {
        perror("strdup");
        return 1;
    }

    /* Entferne Suffix */
    char *pos = strstr(input, suffix);
    if (pos) {
        memmove(pos, pos + strlen(suffix), strlen(pos + strlen(suffix)) + 1);
    }

    size_t len = strlen(input);
    char *result = malloc(len + strlen(suffix) + 1);
    if (!result) {
        perror("malloc");
        free(input);
        return 1;
    }

    size_t r = 0;
    for (size_t i = 0; i < len; i++) {
        char c = input[i];
        int idx;

        if ((idx = find_index(lower, c)) != -1) {
            result[r++] = rot13[idx];
        } else if ((idx = find_index(upper, c)) != -1) {
            result[r++] = ROT13[idx];
        } else if ((idx = find_index(speci, c)) != -1) {
            result[r++] = spe13[idx];
        } else {
            result[r++] = c;
        }
    }

    result[r] = '\0';

    if (!strchr(result, '@')) {
        strcat(result, suffix);
    }

    printf("%s\n", result);

    free(input);
    free(result);
    return 0;
}
