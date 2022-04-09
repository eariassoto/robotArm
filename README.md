# Robot Arm

This is a very old program that has to be compiled in 32 bits. If you are on a Ubuntu/Debian 64 bits modern OS, you need to install 32 bits OpenGL libraries. I managed to do it this way:

```
# as sudo
apt-get install gcc-multilib
dpkg --add-architecture i386
apt-get update
apt-get install libglu1-mesa-dev:i386 freeglut3-dev:i386
```

