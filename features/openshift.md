---
module_id: openshift
layout: features
title: OpenShift
authors: [xcoulon]
highlighted: true
image_url: ./features/images/openshift_icon_256px.png
feature_order: 3
---
# OpenShift Tooling
## Integrated deployment to the cloud. ##
![](#{site.base_url}/features/images/features-openshift-applicationwizard-reduced.png)

From developing to deploying on OpenShift, JBoss Tools provides you with a fully fledged 
environment for your project and aligns with the standard workflows within Eclipse. 
Using the tooling, you can create and configure your remote container, deploy your application, 
stream remote logs into your local console, access your data and remotely debug the running application.
Creating a new OpenShift Application along into a new or an existing Eclipse Project, 
or importing an existing OpenShift Application into a new or an existing project, the Application Wizard supports all the combinations. 

# OpenShift Explorer View
## The embedded Web Console.
![](#{site.base_url}/features/images/features-openshift-explorerview-reduced.png)

The OpenShift Explorer View lets you connect, get access to domain and application creation, 
set embedded cartridges and execute action such as Port-Forwarding and Tail Files   

# Server Adapter
## Almost like a local server
![](#{site.base_url}/features/images/features-openshift-serversview-reduced.png)
The new OpenShift Server Adapter lets you publish your code changes in a single click. 
It relies on JGit to perform the git commit and push operation in background. 
It also gives you access to actions such as 'Tail Files' and 'Port Forwarding'.    

# Port-forwarding
## Feels like home.
![](#{site.base_url}/features/images/features-openshift-portforwarding-reduced.png)

SSH Port-forwarding lets you bind local ports to remote ports on OpenShift using SSH tunneling. 
You can then connect to local port for data access or application debugging.  

# Tail Files
## Streaming the logs.
![](#{site.base_url}/features/images/features-openshift-tailfiles-reduced.png)

SSH also allows the OpenShift tooling to execute remote commands such a 'tail' on log files, 
which are streamed live into the Eclipse Console.