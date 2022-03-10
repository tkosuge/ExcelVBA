## スパコン停止に伴う日付けディレクトリとstateファイルの作成

スパコンにログインし、本番環境とステージング環境の両方で、指定された日付のディレクトリとstateファイルを作成する。（下記のサンプルは 2019/03/22〜2019/03/24 の3日間）

- コンテナの Runscript `sakura2db_write_generated` を実行して state ファイルを作成する
  - `-d`: YYYYMMDD 形式で日付を指定する

### ステージング環境

    $ singularity run instance://UnicornStaging sakura2db_write_generated -d 20190322
    $ singularity run instance://UnicornStaging sakura2db_write_generated -d 20190323
    $ singularity run instance://UnicornStaging sakura2db_write_generated -d 20190324

### プロダクション環境

    $ singularity run instance://UnicornProduction sakura2db_write_generated -d 20190322
    $ singularity run instance://UnicornProduction sakura2db_write_generated -d 20190323
    $ singularity run instance://UnicornProduction sakura2db_write_generated -d 20190324

### 確認

サブミッション出力ディレクトリ（ステージングの場合は `~/submission-staging`、プロダクションの場合は `~/submission`）に日付ディレクトリがパーミッション 750 (drwxr-x---) で作成され、そこに state ファイルがパーミッション 660 (-rw-rw----) で作成され、ファイルの内容が "generated" であれば OK。以下はプロダクションの場合の例であるが、日付のパターン等は適宜変更が必要。

    $ ls -lF ~/submission
    total 8
    drwxr-x--- 2 w3deasy w3deasy 4096 Jan 25 10:26 20190125/
    drwxr-x--- 2 w3deasy w3deasy 4096 Feb  6 13:15 20190322/
    drwxr-x--- 2 w3deasy w3deasy 4096 Feb  6 13:16 20190323/
    drwxr-x--- 2 w3deasy w3deasy 4096 Feb  6 13:16 20190324/
    $ ls -la ~/submission/2019032[2-4]/state
    -rw-rw---- 1 w3deasy w3deasy 9 Feb  6 13:15 2019 /home/w3deasy/submission/20190322/state
    -rw-rw---- 1 w3deasy w3deasy 9 Feb  6 13:16 2019 /home/w3deasy/submission/20190323/state
    -rw-rw---- 1 w3deasy w3deasy 9 Feb  6 13:16 2019 /home/w3deasy/submission/20190324/state
    $ for i in 2 3 4; do echo "$(cat ~/submission/2019032${i}/state)"; done
    generated
    generated
    generated

## 参考: D-easy をスパコン外で動作させる場合

D-easy コンテナを外部PC等で動作させた場合に state ファイルをスパコン上に作成（送信）する手段の一例。

- スパコンのホストを `at025` とし、SSH でパスフレーズなしでログインが可能であるものとする
- `scp` コマンドでファイルを送信する
    - `-r`: ディレクトリを再帰的にコピーする
    - `-p`: パーミッション等を維持する

外部PC等（Singularity のホスト）で state ファイルを作成する手順は、スパコン上で実行する場合と同様。以下プロダクション環境の場合。

    $ singularity run instance://UnicornProduction sakura2db_write_generated -d 20190322
    $ singularity run instance://UnicornProduction sakura2db_write_generated -d 20190323
    $ singularity run instance://UnicornProduction sakura2db_write_generated -d 20190324

`scp` でホストのサブミッション日付ディレクトリを at025 にコピーする。

    $ cd ~/submission
    $ scp -rp 20190322 at025:~/submission
    $ scp -rp 20190323 at025:~/submission
    $ scp -rp 20190324 at025:~/submission

スパコンにログインし、コピーされたファイルを確認する。

    $ ls -lF ~/submission
    total 8
    drwxr-x--- 2 w3deasy w3deasy 4096 Jan 25 10:26 20190125/
    drwxr-x--- 2 w3deasy w3deasy 4096 Feb  6 13:48 20190322/
    drwxr-x--- 2 w3deasy w3deasy 4096 Feb  6 13:48 20190323/
    drwxr-x--- 2 w3deasy w3deasy 4096 Feb  6 13:48 20190324/
    $ ls -la ~/submission/2019032[2-4]/state
    -rw-rw---- 1 w3deasy w3deasy 9 Feb  6 13:48 2019 /home/w3deasy/submission/20190322/state
    -rw-rw---- 1 w3deasy w3deasy 9 Feb  6 13:48 2019 /home/w3deasy/submission/20190323/state
    -rw-rw---- 1 w3deasy w3deasy 9 Feb  6 13:48 2019 /home/w3deasy/submission/20190324/state
    $ for i in 2 3 4; do echo "$(cat ~/submission/2019032${i}/state)"; done
    generated
    generated
    generated