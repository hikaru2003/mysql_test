#! /bin/bash

function test_() {
    # デフォルト値
    local tables=1
    local table_size=100000
    local threads=32
    local time=60
    local rand_type=pareto
    local filename=tmp

    # 引数 (例: tables=2 threads=64 rand-type=uniform) で上書き
    for arg in "$@"; do
        case "$arg" in
            tables=*)
                tables="${arg#*=}"
                ;;
            table_size=*)
                table_size="${arg#*=}"
                ;;
            threads=*)
                threads="${arg#*=}"
                ;;
            time=*)
                time="${arg#*=}"
                ;;
            rand-type=*)
                rand_type="${arg#*=}"
                ;;
            filename=*)
                filename="${arg#*=}"
                ;;
            *)
                echo "不明なパラメータです: $arg" >&2
                ;;
        esac
    done

    echo "# Environmental Setting
- innodb_read_io_threads = 4
- innodb_write_io_threads = 4
- innodb_spin_wait_delay = 6
- innodb_spin_wait_pause_multiplier = 5
- innodb_sync_spin_loops = 30

# Command
$> ./test_sysbench.sh $@
" > "${filename}.txt"

	taskset -c 1-7,9-15 sysbench oltp_read_write \
        --mysql-host=127.0.0.1 \
        --mysql-port=3306 \
        --mysql-user=root \
        --mysql-password=password \
        --mysql-db=sbtest \
        --tables="$tables" \
        --table_size="$table_size" \
        --threads="$threads" \
        --time="$time" \
        --rand-type="$rand_type" \
        run >> "${filename}.txt"
}

# スクリプトとして実行された場合はコマンドライン引数をそのまま渡す
test_ "$@"
