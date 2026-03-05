#! /bin/bash

# 1. コア数の計算
TOTAL_CORES=$(nproc)
HALF_CORES=$((TOTAL_CORES / 2))

exec_test() {
	DELAY=$1
	taskset -c 1-7,9-15 sysbench oltp_read_write --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password=password --mysql-db=sbtest --tables=1 --table_size=100000 --threads=32 --time=60 run &
	pid=$!
	sudo /home/morisaki/Application/pcm/build/bin/pcm-power 1 -csv=power_log_${DELAY}.csv &
	PCM_POWER_PID=$!
	# sysbenchの実行が終わるまで待機
	echo "sysbench total number of events:"
	wait $pid
	kill -INT $PCM_POWER_PID > /dev/null 2>&1
	python3 grep_watts.py power_log_${DELAY}.csv
}

# Ctrl+C でも止まるようにtrapを設定
trap cleanup SIGINT

exec_test 6
