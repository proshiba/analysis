# フリーのランサムウェアビルダー：Redeemer

最近、ハッキングフォーラムでフリーのランサムウェアビルダーが公開されていました。  
redeemerというものであり、まぁRaaS(Ransomware as a Service)の一種、といえるかと思います。  

![ハッキングフォーラム](https://raw.githubusercontent.com/proshiba/analysis/main/redeemer-ransomware/images/hackforum01.png)

恐ろしいのは、これについては、興味がなくなったらオープンソースにする、といってますし、今後もランサムウェアの脅威は広がっていくのだろうなぁ、と感じさせます。  

### 実際に動かしてみる

とりあえず実際にこれが動作するのかどうか試してみました。暗号化するだけならタダですからね。まぁ自分のパソコンを間違って暗号化したら終了ですが。  

まず、zipで圧縮されて公開されていますので、そのままダウンロードすると以下のようなファイルが存在しています。  

![redeemerキット](https://raw.githubusercontent.com/proshiba/analysis/main/redeemer-ransomware/images/redeemer-kit01.png)  
※build.datというファイルがあったのですが、defenderさんが食べちゃったのでなくなってました。。


実際、この先の手順はいくらでも細かく書けますが、ものがものなので、一応やめておきます。  
ざっくり言えば、`Affiliate Toolkit.exe`というものを実行してランサムウェアを作成。decrypter.exeは復号化時に利用する感じです。  
※Instructions.txtにかなり懇切丁寧に書かれてるので、パソコンに詳しくなくても出来そうなレベルです。  

ちなみに起動時の画面は以下。正直、こいつ自体にバックドアがしかけられたりしてないかな？というのが興味の大きなところでしたが、processhackerやmonitorで見てても怪しい挙動は見当たらず。  

![redeemerキット](https://raw.githubusercontent.com/proshiba/analysis/main/redeemer-ransomware/images/redeemer-kit04.png)

作成したredeemerをvirustotalにアップロードします。ちなみにこいつ自体はパッカー系の機能はない？(間違ってたらごめんなさい!)と思われるので、実際に悪用する奴はそのあたりも検討することになるでしょう。  

![redeemer](https://raw.githubusercontent.com/proshiba/analysis/main/redeemer-ransomware/images/redeemer01.png)
![redeemer](https://raw.githubusercontent.com/proshiba/analysis/main/redeemer-ransomware/images/redeemer02.png)

ハッシュはもともとは存在なし。まぁ指定したメールアドレスなどをexeにまとめてるのでしょうから、当然ですが。検知状況はかなり検知されてますね。上でも言った通り、これを実際に使うのなら検知回避か実行前にAVの無効化または例外設定の実施が必要でしょう。  

最後に実際に暗号化してみました。この辺りの動きはまぁいつも通りのランサムウェア、ですね。

![redeemer](https://raw.githubusercontent.com/proshiba/analysis/main/redeemer-ransomware/images/redeemer03.png)

### どういうビジネスモデルか

当然ですが、作り手はこれを使って金儲けをすることを目指してます。やり方はよくあるやつで、入手した身代金の何％かをもらう、という形。
今回は身代金はMonero(仮想通貨)限定であり、20%が作成者の取り分になってます。  

当然、こんなものを作った人が善意に則り紳士協定で払ってくれると期待しないですから、復号化には制限があり、ツールキットの作成者とやり取り(ここで支払う)の上で復号化キーが入手できるようです。  

昔ながらの感じがしますが、こういうものが無償で手に入ってしまうことは怖いところですね。  

### 終わりに

実際、このランサムウェアの動作の詳細などをもう少し細かく追いかけてみたいと思いますが、それはまた気が向いたときにでも。  

今回思うのは、このランサムウェアの流行はまだまだ終わらなそうだな、ということです。  
今年に入ってからぐらいは本当に被害者も多いですからね。。

では終了します。ありがとうございました。

