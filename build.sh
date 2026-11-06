#!/bin/bash

LIBFT_ARCHIVE_PATH=$1
if [ -z "$LIBFT_ARCHIVE_PATH" ]; then
    echo "Usage: ./build.sh <path/to/libft.a>"
    exit 1
fi

if [ ! -f "$LIBFT_ARCHIVE_PATH" ]; then
    echo "Error: Archive file '$LIBFT_ARCHIVE_PATH' not found."
    exit 1
fi

NAME="tester"
OS_NAME=$(uname -s)
COMPILER=gcc
TESTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTER_SOURCE_FILE="$TESTER_DIR/source/main.c"
TESTER_OBJ_FILE="$TESTER_DIR/tester.o"
CFLAGS="-Wall -Wextra -Werror -Wno-unused-function -Wno-unused-variable -I$TESTER_DIR/source/third_party"

if [[ "$OS_NAME" = "Linux" ]]; then
    OS_CFLAGS="-fno-PIE"
    LDFLAGS="-lm -lbsd"
    LINK_FLAGS="-Wl,--whole-archive \"$LIBFT_ARCHIVE_PATH\" -Wl,--no-whole-archive -Wl,--wrap=malloc -Wl,--wrap=free -no-pie"
elif [[ "$OS_NAME" = "Darwin" ]]; then
    OS_CFLAGS="-fPIE"
    LDFLAGS="-lm"

    ALLOWED_UNDEFINED=""
    for func in ft_isalpha ft_isdigit ft_isalnum ft_isascii ft_isprint ft_strlen ft_memset \
                ft_bzero ft_memcpy ft_memmove ft_strlcpy ft_strlcat ft_toupper ft_tolower \
                ft_strchr ft_strncmp ft_memchr ft_memcmp ft_strnstr ft_atoi ft_calloc ft_strdup \
                ft_substr ft_strjoin ft_strtrim ft_split ft_itoa ft_strmapi ft_striteri \
                ft_putchar_fd ft_putstr_fd ft_putendl_fd ft_putnbr_fd \
                ft_lstnew ft_lstadd_front ft_lstsize ft_lstlast ft_lstadd_back ft_lstdelone \
                ft_lstclear ft_lstiter ft_lstmap; do
        ALLOWED_UNDEFINED="$ALLOWED_UNDEFINED -Wl,-U,_$func"
    done

    LINK_FLAGS="-Wl,-force_load -Wl,\"$LIBFT_ARCHIVE_PATH\" $ALLOWED_UNDEFINED"
else
    echo "Error: OS '$OS_NAME' not supported."
    exit 1
fi

if [ ! -f "$TESTER_OBJ_FILE" ] || [ "$TESTER_SOURCE_FILE" -nt "$TESTER_OBJ_FILE" ]; then
    $COMPILER $CFLAGS $OS_CFLAGS -c "$TESTER_SOURCE_FILE" -o "$TESTER_OBJ_FILE"
    if [[ $? -ne 0 ]]; then
        echo "Compilation failed."
        exit 1
    fi
fi

eval $COMPILER $CFLAGS $OS_CFLAGS "$TESTER_OBJ_FILE" $LINK_FLAGS $LDFLAGS -o $NAME

if [[ $? -eq 0 ]]; then
    echo "Build successful: $NAME"
else
    echo "Build failed."
    exit 1
fi
