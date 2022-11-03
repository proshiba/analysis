# Emotetを見てみる

Emotetが再開しましたね。  
おそらく今SOCサービスなどをやっている方は毎秒レベルでため息をしているのでしょうね。。私も思い出すと「う、、頭が」て感じになります。

まぁ、そんなことを言ってても仕方ないので現状を見てみましょう。  

まずは、URLhausです。  
![urlhaus_stats](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/stats02.png)
引用元：https://urlhaus.abuse.ch/browse/tag/emotet/

次にmalware bazaarです。

![malware_bazaar_stats](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/stats01.png)
引用元：https://bazaar.abuse.ch/browse/tag/Emotet/

どちらもそうですが、11/3の朝に取ったので11/3は減ってみえるだけです。ご注意を。  

さて、今は小山ですが11/2 17:00(+09:00)から開始したので、こんなもんってだけでしょう。既に日本語のスパムも飛んでいるようですので要警戒です。  

ちなみに、Emotetについて最新の情報を知りたいなら正確性も踏まえて以下のtwitterアカウントをフォローしておくことを推奨します。  

- `@Cryptolaemus1`

### 解析開始

##### ばらまきの状態を知る

まず、ちょっと思ったのが初期感染はどういうものが多いのかな？という点です。  

以下でデータを取って内容を見てみました。

```bash
curl -d "query=get_taginfo&tag=emotet&limit=1000" https://mb-api.abuse.ch/api/v1/ -o malware.txt
```

どうやら、ほとんどはexe形式のようですね。後はxls(及びxlsx)とitaのタグが多いです。  
どうやらlnkの形式ではあまり投げられてないのですかね？まだまだこれからばらまかれるからアップロードされてないだけかもしれませんが。

- タグ一覧  


タグ | 件数 |
---------|----------|
Emotet|81
exe|73
Heodo|54
xls|5
SilentBuilder|4
ITA|2
xlsx|2
dll|2
e5|2
epoch5|2
zip|1
xrO0NFrgpw1FGZ|1
E4|1
epoch4|1


次にURLhausに上がっているURL情報です。  
とはいえ、おそらく前のEmotetと同じくこれらのホストは侵害されてマルウェアを配布に利用させられている状態になってしまっているだけなのでしょうが。  

ちなみに日本の法律だとマルウェア配布をすることは違法なので、これを放置していると悪用されたとはいえ捕まることにもなりかねないと思います。  
Note: あくまで日本なら、の話です。

パット見て思ったのは、URLの最後に「...」がつくのがおおい？ということですね。件数が少ないので何とも言い難いですが。  

また28件中、httpsが4件で後はhttpになってます。

- hxxp://www[.]mountaineering[.]org[.]tw/jp[.]bad/WWhvAMe...
- hxxp://times[.]my/wp-includes/1OgxQPFaUhS/
- hxxp://vourakilina[.]gr/6vtelq/Xo7C7m/
- hxxp://canterapola[.]es/semihibernation/5H44GMEZ1...
- hxxp://www[.]angloextrema[.]com[.]br/assets/mQVRrHu7o...
- hxxp://www[.]thebeginningstore[.]in/0202498070/m2x8...
- hxxp://alvaovillagecamping[.]pt/wp-content/Ra9iwO...
- hxxp://sourceintership[.]com/vendor/rZnJL9pPUjA9pU/
- hxxp://wordpress[.]xinmoshiwang[.]com/list/cRIH9Bd/
- hxxp://ruitaiwz[.]com/wp-admin/sV1NeVxLDiHJ1xm/
- hxxp://cultura[.]educad[.]pe/wp-content/A86I7QxwuEZV/
- hxxp://voinet[.]ca/cgi-bin/RXDWHpi8dHHZf8/
- hxxps://atlantia[.]sca[.]org/php_fragments/D8Nwm2F8...
- hxxp://thuybaohuy[.]com/wp-content/u3MJwXSP9tmiaT...
- hxxps://amorecuidados[.]com[.]br/wp-admin/t3D/
- hxxp://aibwireless[.]com/cgi-bin/zR2mG25Ssk8dH/
- hxxp://navylin[.]com/bsavxiv/axHQYKl/
- hxxp://sat7ate[.]com/wordpress/ZAf5j4MG8Hwnig/
- hxxp://www[.]spinbalence[.]com/Adapter/moycMR/
- hxxp://www[.]3d-stickers[.]com/Content/Afa1PcRuxh/
- hxxp://yuanliao[.]raluking[.]com/overemotionality/V...
- hxxp://hsweixintp[.]com/wp-admin/3c2etiFC2RwmHfTS/
- hxxp://9hym[.]com/images/SXVIe4tbJw8ZCfa4TEt/
- hxxp://helpeve[.]com/multiwp/cxpkaAkAKPRUs4KL/
- hxxps://audioselec[.]com/about/dDw5ggtyMojggTqhc/
- hxxps://geringer-muehle[.]de/wp-admin/G/
- hxxp://intolove[.]co[.]uk/wp-admin/FbGhiWtrEzrQ/
- hxxp://isc[.]net[.]ua/themes/3rU/


さぁ、最後にthreatfoxのデータも一応見ておきましょうか。  

```bash
curl -X POST https://threatfox-api.abuse.ch/api/v1/ -d '{ "query": "taginfo", "tag": "emotet", "limit": 1000 }'
```

こっちはC2のIPが上がってます。以下になってますね。  
ほとんどは443で1つが8080。これはプロキシ利用だったりしないかな？という気がしますね。  

- 186[.]250[.]48[.]5:443
- 149[.]28[.]143[.]92:443
- 169[.]60[.]181[.]70:8080
- 182[.]162[.]143[.]56:443

どれも、現在も接続可能ですね。  
shodanではまだデータが新しくなってないのかいくつかポート空いてないですが、以下で試すと普通にほとんどの場所からつながります。  

- https://check-host.net/check-tcp

あとIP4つともホスティングですが、国も上から順に以下となっていて見事にバラバラです。  
- ブラジル
- シンガポール
- アメリカ
- 韓国

ちなみに[runcurl](https://reqbin.com/curl)で試しにアクセスしてみたら空ページでした。

![runcurl-result](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/runcurl01.png)

さて、次は実際にマルウェアを見てみましょう。  

##### マルウェアを見る

さて、まずはxlsファイルを見ていきたいと思います。  

- hash: sha256  
- URL: https://www.virustotal.com/gui/file/ef2ce641a4e9f270eea626e8e4800b0b97b4a436c40e7af30aeb6f02566b809c

![virustotal01](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/virustotal01.png)

FirstSubmitが昨日の17:21(+09:00)ですし、かなり検知されてますね。  
ちなみに、名称は以下など(表示の上から10のみ抜粋)です。前からよくあるような名前がありますね。  

- Address Changed.xls 
- Report.xls 
- Rech.xls 
- Scan 2022.02.11_1154.xls 
- Rechnungs-Details 2022.02.11_1615.xls 
- RechnungsDetails 2022.02.11_1053.xls 
- Form - 02 Nov, 2022.xls 
- Q95097909266YY.xls 
- Invoice Number 269299 02-11-2022_1356.xls 

日付が入っているものが多い様ですね。ちなみに「2022.02.11」は「yyyy.dd.mm」て形式なんでしょうかね。。  

次にbehaviorを見てみます。  

![virustotal01](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/virustotal02.png)

見る限り、**少なくともこの検体は***前のEmotetと同じような動きをしているように見えます。  
そう思ったところを以下に書きますね。  
1. ocxファイルやregsvr32が使われるところ
2. システム権限取れる場合(だと思われる)はsystem32の下にランダム文字列のフォルダを作ってその中にdllを置く
3. その他のユーザはappdata\local下にランダム文字列のフォルダを作ってDLLを置く
4. ocxファイルを動かすregsvr32のコマンドが「..\filename.ocx」と先頭に「..」をつけてるところ(今回は拡張子をooccxxにはしてますね)

excelから直でregsvr32を起動するタイプとpowershellを介するタイプが昔はあったと思いますが、これはexcelから直接のようですね。  

うーん、この先のDLLの機能には大きな違いがあるのかもしれませんが、ちょっとわかりませんね。。  
あと、EXEファイルのアップロードが多かったですが、これはDLLなのか。まぁしょうがないです。  

さて、まずはoletoolsでマクロの内容を見てみます。  

```dos
olevba .\emotet.xls
```

そうすると以下みたいな感じです。やっぱり前と同じでシートにコマンドを埋め込んでますね。  

```vb
'  Sheet,D5,T("System32\"),""
'  Sheet,L8,T( Shee!F28& Shee!H28& Shee!H28& Shee!H26),""
'  Sheet,R13,T( Shee!H28& Shee!H28& Shee!H26),""
'  Sheet,J14,T( Shee!F10& Shee!C16& Shee!O18& Shee!B3),""
'  Sheet,F19,T(":\Windows\"),""
'  Sheet,M26,T( Shee!F24& Shee!F26& Shee!O11& Shee!F26& Shee!O11& Shee!L31),""
```

また、マクロについてはworkbookを開いたら自動実行されるようです。  
とはいえ、正直マクロがデフォルト無効になった今としては、どこまで実行されるのか、て感じですね。  

正直、全部parseするのはしんどい（意味もないかと思います）ので、通信先と思われる情報だけ以下に書きます。

- audioselec[.]com
- isc[.]net[.]ua
- intolove[.]co[.]uk

試しにダウンロードしてみたところ、これができました。珍しいですね、結構生きてる時間短いことが多いのに。以下のコマンドでやってみました。  

- ダウンロードコマンド

```ps
(new-object system.net.webclient).downloadfile("hxxp://intolove[.]co[.]uk/wp-admin/FbGhiWtrEzrQ/", "$env:userprofile\desktop\malware.bin")
```
Note: デファングしてます

ダウンロード後のハッシュは以下となっています。これもvirustotalで検知されてますね。  

- hash: f91ff6f6cd234bf1d80580d95734416c31ac6f7a9454eb224980de1cddeb0b84

```ps
PS C:\Users\Administrator\Desktop> certutil.exe -hashfile .\malware.bin sha256
SHA256 hash of .\malware.bin:
f91ff6f6cd234bf1d80580d95734416c31ac6f7a9454eb224980de1cddeb0b84
```

![virustotal03](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/virustotal03.png)

中身を少し見てみましたが、まぁDLLですね。  

![binary01](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/binary01.png)

正直、私はバイナリの分析ができないので、ここから先はプロにお任せしましょうかね。。  

一応、`DllRegisterServer`からの処理が以下になってます。  
`FUN_1800006d30`関数をコールして、その受け取りが多分ポインタアドレス何でしょうね。  
返り値をコール（`(*pcVar1)()`）してます。

```c
undefined8 DllRegisterServer(void)
{
    code *pcVar1;
    /* 0x6e30  1  DllRegisterServer */
    pcVar1 = (code *)FUN_180006d30(DAT_1800902f8,"ZJKfDxsqUt");
    (*pcVar1)();
    return 0;
}


// param_1 -> DAT_1800902f8, param_2 -> "ZJKfDxsqUt"
longlong FUN_180006d30(longlong param_1,char *param_2)

{
  uint uVar1;
  uint uVar2;
  uint uVar3;
  int iVar4;
  longlong lVar5;
  uint local_48;
  
  // 省略
  return param_1 + /* 後略 */ ;
}
```
Note: これで実行はできないですが、マルウェア内のコードですし、念のため消しました。ghidraでimportすればすぐ見れます

##### ITAタグのものって何？

ITAタグが付いてるやつってどんなものかな？と思ってみてみました。  
見たのは以下です。  

- hash: c52d9c7a51b8e955155e8d44f609a015c68bc134e631a3c77efa46e997790a48
- URL: https://bazaar.abuse.ch/sample/c52d9c7a51b8e955155e8d44f609a015c68bc134e631a3c77efa46e997790a48/

そしたらどうやらこれもexcelファイルですね。実際に開いた結果が以下です。  

![itafile](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/itafile01.png)

##### exe形式のものってどう動く？

以下ハッシュのものを見てみました。

- hash: 6dc91ded76fbf0ac3a909cba9487665856ad36b9081fe10305e5dfde9fb86eab
- URL: https://bazaar.abuse.ch/sample/6dc91ded76fbf0ac3a909cba9487665856ad36b9081fe10305e5dfde9fb86eab/

ダウンロードしてみると以下のようなファイルになっています。  

![exetype01](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/exetype01.png)

ただ、virustotalで見てみるとDLLファイルになっていますね。ちなみに、ghidraで見ても`DllRegisterServer`があります。  

![exetype02](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/exetype02.png)

![exetype03](https://raw.githubusercontent.com/proshiba/analysis/main/emotet/emotet_221103/images/exetype03.png)

virustotalのbehaviorを見てもほぼ変わらない気がします。結局は物は変わらないのかな？て感じですね。。  
ただ、ちょっと詳しくなくてわからないのですが、`exe`と`dll`でどっちも動くようにできるのでしょうかね？  
まぁどっちもPEファイルで基本構造は変わらないのでできるのかな、て感じですが。。

### 終わりに

バイナリの解析ができないとな、と思ってしまいますね。。  
とりあえず、少なくとも感染初期における流れは変わらなそう、て感じです。  

今度、もっとghidra使えるようになったら更新したいと思います。

以上、ありがとうございました！
