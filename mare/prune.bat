set RESTIC_PATH=c:\Users\User\Desktop\restic.exe
set RESTIC_REPOSITORY=e:\mare-restic
set RESTIC_PASSWORD=fillthisin

%RESTIC_PATH% forget -g "" --keep-within 6m
%RESTIC_PATH% prune
%RESTIC_PATH% check

pause
