CC       ?= gcc
CFLAGS   := -std=c89 -Wall -Wextra -Werror -O3 -g
LDFLAGS  := -lm
HDRS      = $(wildcard *.h)
SRCS      = $(wildcard *.c)
OBJDIR    = objdir
OBJS      = $(addprefix ${OBJDIR}/,$(patsubst %.c,%.o,$(SRCS)))
DIR       = $(shell basename ${CURDIR})
PROGRAM   = ${OBJDIR}/test_${DIR}

.PHONY: clean

all: ${PROGRAM}

test: ${PROGRAM}
	./${PROGRAM}

${PROGRAM}: ${OBJS}
	${CC} $^ -o $@ ${LDFLAGS}

${OBJDIR}/%.o : %.c
	${CC} ${CFLAGS} -c $< -o $@

${OBJS}: $(HDRS) | ${OBJDIR}

${OBJDIR}:
	mkdir -p $@

clean:
	${RM} -r ${OBJDIR}
