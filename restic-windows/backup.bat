set RESTIC_PATH=c:\Users\User\Desktop\restic.exe
set RESTIC_REPOSITORY=e:\mare-restic
set RESTIC_PASSWORD=fillthisin

%RESTIC_PATH% self-update
%RESTIC_PATH% backup --use-fs-snapshot --exclude="C:\Users\User\AppData\Local\Microsoft\WindowsApps" "C:\Users\User" "C:\Program Files (x86)\Steam\steamapps\common\Master Of Pottery"

pause
