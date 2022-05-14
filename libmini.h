#ifndef _LIB_MINI_H
#define _LIB_MINI_H

typedef long long size_t; 
typedef long long ssize_t;  
typedef long long off_t;    

typedef int mode_t;
typedef int uid_t;
typedef int gid_t;
typedef int pid_t;

extern long errno;
#define NULL ((void*) 0)

#define O_ACCMODE	00000003
#define O_RDONLY	00000000
#define O_WRONLY	00000001
#define O_RDWR		00000002
#define O_CREAT		00000100

#define O_EXCL		00000200	/* not fcntl */
#define O_NOCTTY	00000400	/* not fcntl */
#define O_TRUNC		00001000	/* not fcntl */
#define O_APPEND	00002000
#define O_NONBLOCK	00004000
#define O_DSYNC		00010000	/* used to be O_SYNC, see below */
#define FASYNC		00020000	/* fcntl, for BSD compatibility */
#define O_DIRECT	00040000	/* direct disk access hint */
#define O_LARGEFILE	00100000
#define O_DIRECTORY	00200000	/* must be a directory */
#define O_NOFOLLOW	00400000	/* don't follow links */
#define O_NOATIME	01000000
#define O_CLOEXEC	02000000	/* set close_on_exec */

// typedef struct jmp_buf_s {
// 	long long reg[8];
// 	sigset_t mask;
// } jmp_buf[1];


struct timespec {
    long   ts_sec;
    long   ts_nsec;
};

long sys_nanosleep(struct timespec *rqtp, struct timespec *rmtp);

ssize_t write(int fd, const void *buf, size_t count);
size_t strlen(const char *s);
unsigned int sleep(unsigned int seconds);


#endif //_LIB_MINI_H