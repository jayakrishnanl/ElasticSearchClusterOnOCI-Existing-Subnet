# Work In Progress
# ElasticSearchClusterOnOCI-Existing-Subnet

## Pre-requisites
- Create or chose existing Public Subnets where Bastion and Private Subnets where ES Master and Data nodes are to be launched. 

Make sure you create the Subnets across the available ADs.

- Tag (freeform-tag) the Public and Private Subnets using the following format:
```
Public Subnet on AD1 --> subnet:public-AD1
Public Subnet on AD2 --> subnet:public-AD2
Public Subnet on AD3 --> subnet:public-AD3

Private Subnet on AD1 --> subnet:private-AD1
Private Subnet on AD2 --> subnet:private-AD2
Private Subnet on AD3 --> subnet:private-AD3
```
Refer: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcetags.htm#workingtags

## Acknowledgement: 
Folks who contributed with code, feedback, ideas, testing etc:
-  Jeet Jagasia

