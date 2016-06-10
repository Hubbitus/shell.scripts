' http://habrahabr.ru/qa/4329/#answer_18829 and then fixed by author by request in Skype!
' Thank you to Никита Абдуллин

argc = WScript.Arguments.Count
set argv = WScript.Arguments
if argc < 1 then 
 WScript.Echo "Usage: sudo <command> <arg1 arg2 .. argN>"
 WScript.quit
end if

set objShell = CreateObject("Shell.Application") 
set FSO = CreateObject("Scripting.FileSystemObject")
dim str

if argv(0) = "sudo" then
 for i = 3 to argc-1
  str = str + " " + argv(i)
 next
 objShell.ShellExecute argv(2), str, argv(1), "open", 1
else
 for i = 0 to argc-1
  str = str + " " + argv(i)
 next
 curPath = FSO.GetAbsolutePathName(".")
 objShell.ShellExecute "wscript.exe", _ 
  Chr(34) & WScript.ScriptFullName & Chr(34) & _ 
  " sudo " & Chr(34) & curPath & Chr(34) & str, _
  "", "runas", 1
end if