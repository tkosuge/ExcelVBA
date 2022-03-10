「環境構築手順書」に準じ外部PC等にて D-easy コンテナを動作させ、当日（厳密に言うと日付が変わった直後の前日）の Submission 出力をスパコンにコピーする設定。

- state ファイルが作成される日次の cron ジョブが0時5分に実行されているものとする
- 毎日0時10分に前日の Submission 日付ディレクトリを送信する cron ジョブを登録する
- スパコンのホストを `at025` とし、SSH でパスフレーズなしでログインが可能であるものとする
- `scp` コマンドでファイルを送信する
    - `-r`: ディレクトリを再帰的にコピーする
    - `-p`: パーミッション等を維持する
    - `-q`: 進行状況等を表示しない

## ステージング環境

    10 0 * * * /bin/bash -l -c 'cd ~/submission-staging && scp -rpq `date -d "1 day ago" "+%Y%m%d"` at025:~/submission-staging'

## プロダクション環境

    10 0 * * * /bin/bash -l -c 'cd ~/submission && scp -rpq `date -d "1 day ago" "+%Y%m%d"` at025:~/submission'