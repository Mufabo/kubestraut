apiVersion: v1
kind: Pod
metadata:
  name: logger
  labels:
    app: logger
spec:
  containers:
    - name: logger
      image: busybox:1.36
      command:
        - sh
        - -c
        - |
          while true; do
            echo "heartbeat ok"
            echo "activation-code=__CODE__"
            sleep 5
          done
