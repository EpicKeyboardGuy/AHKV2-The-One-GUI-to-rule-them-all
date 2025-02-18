/*
==============================================================================================================================================================================
¤	B64 File Lib	                --->	Functions to create and use B64 Data.

        f_FileToB64	                --->	Read original file     +     Write a .txt file containing B64 values
        f_FileFromB64String 	    --->	Re-create original file from B64 String

		--->	By Epic Keyboard Guy
		--->	Last Modified : 2025-02-17
==============================================================================================================================================================================
*/

If (A_ScriptName = "B64 File Lib.ahk")
{
    ExitApp ; Meaning : This script is not runnable by itself, it needs to be included. (with #Include)
}

#Requires AutoHotKey v2

/*
==============================================================================================================================================================================
¤	f_FileToB64	--->	Read original file     +     Write a .txt file containing B64 values
==============================================================================================================================================================================
*/

f_FileToB64(str_OriginalFile_FullPath := "", str_B64File_FullPath := str_OriginalFile_FullPath . ".B64.txt")
{
    PTR         := "Ptr"
    DWORD       := "UInt"
    DWORDP      := "UIntP"
    LPSTR       := "Ptr"
    LPCSTR      := "Ptr"

    if (str_OriginalFile_FullPath = "" || !IsObject(obj_OriginalFile := FileOpen(str_OriginalFile_FullPath, "r")))
    {
        MsgBox("Can't read file : `n`n" . str_OriginalFile_FullPath)
        return false
    }

    if (str_B64File_FullPath = "" || !IsObject(obj_B64File := FileOpen(str_B64File_FullPath, "w")))
    {
        MsgBox("Can't write file : `n`n" . str_B64File_FullPath)
        return false
    }

    buf_OriginalFile := Buffer(obj_OriginalFile.Length)
    obj_OriginalFile.RawRead(buf_OriginalFile)
    obj_OriginalFile.Close()

    ; https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-CryptBinaryToStringA
    If !(DllCall("Crypt32.dll\CryptBinaryToStringA",
                    PTR     , buf_OriginalFile,
                    DWORD   , buf_OriginalFile.Size,
                    DWORD   , 0x40000001,                         ; 0x40000001 = Base64, without headers. No CR/LF
                    LPSTR   , 0,
                    DWORDP  , &var_ReturnSize := 0
                )
        )
    {
        Return false
    }

    buf_B64String := Buffer(var_ReturnSize, 0)

    If !(DllCall("Crypt32.dll\CryptBinaryToStringA",
                    PTR     , buf_OriginalFile,
                    DWORD   , buf_OriginalFile.Size,
                    DWORD   , 0x40000001,                         ; 0x40000001 = Base64, without headers. No CR/LF
                    LPSTR   , buf_B64String,
                    DWORDP  , &var_ReturnSize
                )
    )
    {
        Return false
    }

    obj_B64File.RawWrite(buf_B64String)
    obj_B64File.Close()

    return true
}


/*
==============================================================================================================================================================================
¤	f_FileFromB64String 	--->	Re-create original file from B64 String
==============================================================================================================================================================================
*/

f_FileFromB64String(str_B64 := "", str_FileToWrite_FullPath := "")
{
    PTR         := "Ptr"
    DWORD       := "UInt"
    DWORDP      := "UIntP"
    LPSTR       := "Ptr"
    LPCSTR      := "Ptr"
    
	if (str_B64 = "")
    {
        MsgBox("str_B64 = `"`"")
        return false
    }

	if (str_FileToWrite_FullPath = "" || !IsObject(obj_FileToWrite := FileOpen(str_FileToWrite_FullPath, "w")))
    {
        MsgBox("Can't write `n`n" . str_FileToWrite_FullPath)
        return false
    }

    ; https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinarya
    If !(DllCall("Crypt32.dll\CryptStringToBinary",
                    LPCSTR  , StrPtr(str_B64),          ; A pointer to a string that contains the formatted string to be converted.
                    DWORD   , 0,                        ; 0 = Null-terminated string
                    DWORD   , 0x01,                     ; 0x01 = Base64, without headers.
                    PTR     , 0,                        ; 0 the first time to calculate the size needed
                    DWORDP  , &var_Size := 0,           ; Will receive the calculated number of bytes required
                    DWORDP  , 0,                        ; Optional
                    DWORDP  , 0                         ; Optional
                )
        )
    {
        Return False
    }

    buf_FileToWrite := Buffer(var_Size, 0)

    If !(DllCall("Crypt32.dll\CryptStringToBinary",
                    LPCSTR  , StrPtr(str_B64),          ; A pointer to a string that contains the formatted string to be converted.
                    DWORD   , 0,                        ; 0 = Null-terminated string
                    DWORD   , 0x01,                     ; 0x01 = Base64, without headers.
                    PTR     , buf_FileToWrite,          ; A pointer to a buffer that receives the returned sequence of bytes
                    DWORDP  , &var_Size,                ; Will receive the calculated number of bytes required
                    DWORDP  , 0,                        ; Optional
                    DWORDP  , 0                         ; Optional
                )
        )
    {
        Return False
    }

    obj_FileToWrite.RawWrite(buf_FileToWrite)
    obj_FileToWrite.Close()

    return true
}
