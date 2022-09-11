# Bumblebeeを見てみる

BumblebeeはIcedIDやbazaarLoaderから切り替わって利用されると話題にされたマルウェア(loader)です。  
IcedIDを見たときにどうせだからこっちも見てみようと思いまして、調べてみました。  
まぁ正直、bleepingcomputerに詳細が載ってるので私の情報載せる意味ないのですが。まぁ勉強ついでということでお付き合い下さい。  

https://www.bleepingcomputer.com/news/security/bumblebee-malware-adds-post-exploitation-tool-for-stealthy-infections/


### 対象マルウェア

以下になります。毎度おなじみのmalware bazaarにあります。

- sha256: a896dcc08e5ade583fd9c579c75e3e1b1249e7a873e37ca4a7c11ef363fa8cff  
- URL: https://bazaar.abuse.ch/sample/a896dcc08e5ade583fd9c579c75e3e1b1249e7a873e37ca4a7c11ef363fa8cff/

### 調査してみる

では、まずはzipを開いてみます。そうすると今度は`img`ファイルですね。まぁこれも`iso`と同じようなものです。  

![zipfile](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/zip-file.png)

内容を見てみますと、隠しファイルのDLLとlnkファイルになっています。ありがちですね。  

![lnkfile](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/lnk-file.png)

Lnkの内容は以下になってます。  
```dos
C:\Windows\System32\odbcconf.exe /a {REGSVR DFSdDHyafGNBMb.dll}
```

正直、やってることはなんとなくわかりますが`odbcconf.exe`を使ってるのは可能なのかな？と思ってLoLBASで見てみました。  
そうすると確かにあるようですね。

![odbcconf](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/odbcconf.png)  
引用： https://lolbas-project.github.io/lolbas/Binaries/Odbcconf/

Note: LoLBASはLoL(Living of the Land)によって利用される各種バイナリとその用途が記載されてあります。  

なるほど。。odbcconfでdll実行ができるのですね。これは勉強になりました。  

このDLLファイルのsha256は以下になります。  
sha256: f1aa85cd3d3ed3d2b3ff8e705d81c32d2e7794208f7f7a76f7314ef408b897d2

さて、DLLを見てみましょうか。  
以下はvirustotalの検出です。数日たってますから既に大量に検知されてますね。  
![virustotal01](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/vt-file01.png)

relationを見ると通信先は２つ。ただし、どちらも検知ゼロです。  

![virustotal02](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/vt-file02.png)  

それもそのはず。通信先のIPはどちらもmicrosoftになってます。IaaS利用でしょうね。  
1)
![virustotal02](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/vt-file03.png)
2)
![virustotal02](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/vt-file04.png)

その他、サンドボックスの実行結果は正直あまり見るところはないですが。１つ見ておいた方がいいかと思うのは以下です。  

![virustotal02](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/vt-file05.png)

サンドボックス実行検知系ですね。  
どういうことが確認されるのかを理解しておくのはいいと思います。  

しかし、これbleepingcomputerに乗ってるやつじゃないですね。。powershell使うやつ見ようとしてましたが。。

というわけで、もう１つ見てみましょう。以下のハッシュです。  
これもmalware bazaarにありました。  

sha256: e9a1ce3417838013412f81425ef74a37608754586722e00cacb333ba88eb9aa7
URL: https://bazaar.abuse.ch/sample/e9a1ce3417838013412f81425ef74a37608754586722e00cacb333ba88eb9aa7/

![vhdfile01](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/vhd-file01.png)

```dos
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ep bypass -file lkndwsjds.ps1
```

正直、いつも通りですね。。vhdというイメージ形式になっただけで`ps1(powershell)`のスクリプトとそのリンクファイルです。  

では、スクリプトを見てみましょう。  

![psfile01](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/ps-file01.png)  

うん、よくあるobfuscationですね。  
下の方を見るととても分かりやすいです。  

![psfile02](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/ps-file02.png)  

では、少しわかりやすくします。  

```powershell
$dtPrEr = ""
foreach ($element in $acdukLom) {
    $data = [System.Convert]::FromBase64String($element)
    $ms = New-Object "System.IO.MemoryStream"
    $ms.Write($data, 0, $data.Length)
    $ms.Seek(0,0) | Out-Null
    $somObj = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
    $drD = New-Object System.IO.StreamReader($somObj)
    $vVar = $drD.readtoend.Invoke()
    $dtPrEr += $vVar
}

$scriptPath = $MyInvocation.MyCommand.Path
$dtPrEr | iex
```

この最後に入っている`iex`がわかりやすくついてくれてるでありがたいですね。  
このコードは内容がgzipstreamを解凍して作ってるので実行しないと内容が見れません。  
なので、IEXなしで実行してみましょう。
そうすると以下になります。

![psfile03](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/ps-file03.png)  

ちなみにスクリプトの最後の方は以下。  

```powershell
$TIBpoA = $mbVar
$TIBpoA[0] = 0x4d
Invoke-pMnPDC -LdDataHpo $TIBpoA
```

まぁ、つまりinvoke-pmnpdcを実行するということですね。  

次に、この関数の末尾を見ると以下になってます。  

```powershell
Function sOFIZv
{
	$e_magic = ($LdDataHpo[0..1] | % {[Char] $_}) -join ''

	if ($e_magic -ne 'MZ')
	{
	    throw 'PE is not a valid PE file.'
	}

	Invoke-Command -ScriptBlock $deySdT -ArgumentList @($LdDataHpo, $Holksjwio)
}
sOFIZv
```

次に以下を見てみますとpowershellスクリプトでDLLロードして実行しようとしているように見えます。  

```powershell
$DllMain.Invoke($lBnGsi.PEHandle, 0, [IntPtr]::Zero) | Out-Null
$Success = $Win32Functions.VirtualFree.Invoke($PEHandle, [UInt64]0, $Win32Constants.MEM_RELEASE)
```

ということで、そもそもこの関数呼び出し時に渡されたデータはおそらくDLLと思い、以下のように書いてファイルに書きだしました。  

```powershell
[System.IO.File]::WriteAllBytes("out.dll", $TIBpoA)
```

この上で、IDAで開くとちゃんと開けます。やっぱりDLLファイルですね。  

![IDA](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/ida-file01.png)

ハッシュは以下です。  

sha256: f156f9741d72f053129135b42822975874cdf10e49f20e1e63efdd3525ccf0f2

virustotalでチェックしましたが、残念ながらこのハッシュは存在しなかったのでアップロードしました。  
そうするとかなり検知されてますね。  

![virustotal](https://raw.githubusercontent.com/proshiba/analysis/main/bumblebee/images/vt-file06.png)

中々面白い内容でした。DLLをファイルに書かずに読み込ませるのは、powershell利用の時では珍しい？気もしますが、どうなんでしょうね。  

### 終わりに。

正直、最初に見たのが最新だと思ったのでちょっと大変でした。  
まぁ中々普段見ないものだったので楽しかったです。

では、本日は終了させていただきます！  
ありがとうございました！
