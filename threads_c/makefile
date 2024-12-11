# Definir variáveis
CC = gcc                    # Compilador C (gcc)
CFLAGS = -g -Wall -Wextra -fopenmp      # Flags de compilação (avisos)
LDFLAGS = -lgomp
# Arquivos fontes e objetos
SRCS_one = appThread.c knn.c
OBJS_one = $(SRCS_one:.c=.o)         # Converte .c para .o (arquivos objetos)
EXEC = app              # Nome do executável final

SRCS_two = ../version_c/list.c
OBJS_two = $(SRCS_two:.c=.o)

# Regra padrão (a primeira regra é executada por padrão)
all: $(EXEC)

# Como criar o executável
$(EXEC): $(OBJS_one) $(OBJS_two)
	$(CC) $(OBJS_one) $(OBJS_two) -o $(EXEC) $(LDFLAGS)

# Como compilar os arquivos .c para .o
%.o: %.c ../version_c/list.h ../version_c/ML.h
	$(CC) $(CFLAGS) -c $< -o $@

# Limpar arquivos temporários (arquivos objetos e executável)
clean:
	rm -f $(OBJS_one) $(OBJS_two) $(EXEC)

# Recompilar tudo do zero
rebuild: clean all