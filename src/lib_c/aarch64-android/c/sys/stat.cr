require "./types"
require "../time"

lib LibC
  S_IFMT   = 0o170000
  S_IFBLK  = 0o060000
  S_IFCHR  = 0o020000
  S_IFIFO  = 0o010000
  S_IFREG  = 0o100000
  S_IFDIR  = 0o040000
  S_IFLNK  = 0o120000
  S_IFSOCK = 0o140000
  S_IRUSR  =    0o400
  S_IWUSR  =    0o200
  S_IXUSR  =    0o100
  S_IRWXU  = 0o400 | 0o200 | 0o100
  S_IRGRP  = S_IRUSR >> 3
  S_IWGRP  = S_IWUSR >> 3
  S_IXGRP  = S_IXUSR >> 3
  S_IRWXG  = S_IRWXU >> 3
  S_IROTH  = S_IRGRP >> 3
  S_IWOTH  = S_IWGRP >> 3
  S_IXOTH  = S_IXGRP >> 3
  S_IRWXO  = S_IRWXG >> 3
  S_ISUID  = 0o4000
  S_ISGID  = 0o2000
  S_ISVTX  = 0o1000

  struct Stat
    st_dev : DevT
    st_ino : InoT
    st_mode : ModeT
    st_nlink : NlinkT
    st_uid : UidT
    st_gid : GidT
    st_rdev : DevT
    __pad1 : ULong
    st_size : OffT
    st_blksize : Int
    __pad2 : Int
    st_blocks : Long
    st_atim : Timespec
    st_mtim : Timespec
    st_ctim : Timespec
    __unused4 : UInt
    __unused5 : UInt
  end

  fun chmod(__path : Char*, __mode : ModeT) : Int
  fun fchmod(__fd : Int, __mode : ModeT) : Int
  fun fstat(__fd : Int, __buf : Stat*) : Int
  fun lstat(__path : Char*, __buf : Stat*) : Int
  fun mkdir(__path : Char*, __mode : ModeT) : Int
  fun stat(__path : Char*, __buf : Stat*) : Int
  fun umask(__mask : ModeT) : ModeT
  fun utimensat(fd : Int, path : Char*, times : Timespec[2], flag : Int) : Int
end
