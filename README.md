# check_aws_status
Monitor the RSS feed on the AWS status Page

##Dependecies
* Ruby 
* Gems
	* choice 	

`gem install choice`

##Usage

	name: check_aws_status.rb
	Usage: check_aws_status.rb [-purspsv]
	name: check_aws_status.rb
	Specific options:
    -p, --protocol=PORT              The protocol to use (default http)
    -u, --url=URL                    The AWS Status URL (default status.aws.amazon.com)
    -r, --region=REGION              The AWS Region to use (default eu-central-1)
    -s, --service=SERVICE            The AWS Service to monitor (default ec2)
	-ps, --proxy_server=PROXY_SERVER  Proxy Server if needed to connect to EC2 (e.g. http://192.168.0.5:3456 no default)
	Common options:
        --help                       Show this message
        --examples                   S3 Status in Ireland (eu-west-1 region): ./check_aws_status.rb -s s3 -r eu-west-1
                                     EC2 Status in North California (us-west-1 region): ./check_aws_status.rb -s ec2 -r us-west-1
                                     S3 Status in Ireland (eu-west-1 region) using a proxy: ./check_aws_status.rb -s s3 -r eu-west-1 -ps http://10.0.0.6:9000
    -v, --version                    Show version
