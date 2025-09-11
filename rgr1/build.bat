set folder=rgr1
set name=main
set asm_path=%folder%\%name%.asm
set obj_path=%name%.obj
set exe_path=%name%.exe
set output_path=%folder%

cd ..
:: Создание объектного файла
ml64 /Cp /c %asm_path%
pause

:: Создание исполняемого файла
link /SUBSYSTEM:CONSOLE /ENTRY:WinMain %obj_path%
pause

:: Удаление объектного файла
del /q %obj_path%

:: Перемещение исполняемого файла
move /Y %exe_path% %output_path%
cd %folder%

%exe_path%
pause