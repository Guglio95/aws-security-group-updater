# AWS Security Group Updater

Docker image to automatically update an AWS security group to allow the host IP.

| Env Name  | Description |
| ------------- | ------------- |
| AWS_ACCESS_KEY_ID  | IAM credentials with permission to edit the security group.  |
| AWS_SECRET_ACCESS_KEY  | IAM credentials with permission to edit the security group.  |
| AWS_DEFAULT_REGION  | Security group's region.  |
| SG_UPDATE_GROUP_ID  | Security group's id.  |
| PROTOCOL  | Protocol to be allowed (e.g.: `tcp`)  |
| FROM_PORT  | Port range start (e.g.: `80`)  |
| TO_PORT  | Port range end (e.g.: `80`)  |
| EXIT_ON_FINISH  | Whether to exit on finish or hang forever (e.g.: `true`)  |

## IAM Policy
Example IAM policy to allow an user to edit a security group.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "sid-0",
            "Effect": "Allow",
            "Action": [
                "ec2:RevokeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress"
            ],
            
            "Resource": "arn:aws:ec2:<region>:<account-id>:security-group/<securiy-group-id>"
        }
    ]
}
```

## Example: K8s Daemosset
You may create a Kubernetes DaemonSet to ensure every cluster-node registers its IP to the AWS Security Group. Existent nodes and next added ones will register their IPs to the security group.

Note that, when a node is evicted, its IP won't be removed from the security group.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: aws-security-group-updater
  namespace: default
spec:
  selector:
    matchLabels:
      name: aws-security-group-updater
  template:
    metadata:
      labels:
        name: aws-security-group-updater
    spec:
      tolerations:
      # this toleration is to have the daemonset runnable on master nodes
      # remove it if your masters can't run pods
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      terminationGracePeriodSeconds: 30
      containers:
      - name: aws-security-group-updater
        image: ghcr.io/guglio95/aws-security-group-updater:v1.0.0
        env:
          - name: AWS_ACCESS_KEY_ID
            value: "AXXXXXXXXXXXXXXXXX"
          - name: AWS_SECRET_ACCESS_KEY
            value: "WXXXXXXXXXXXXXXXXXXXX"
          - name: AWS_DEFAULT_REGION
            value: "eu-central-1"
          - name: SG_UPDATE_GROUP_ID
            value: "sg-00000000000000"
          - name: PROTOCOL
            value: "tcp"
          - name: FROM_PORT
            value: "80"
          - name: TO_PORT
            value: "80"
          - name: EXIT_ON_FINISH
            value: "false"
        resources:
          requests:
            cpu: 10m
            memory: 50Mi
```