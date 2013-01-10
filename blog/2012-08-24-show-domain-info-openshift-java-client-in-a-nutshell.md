---
title: 'show-domain-info: openshift-java-client in a nutshell'
author: 'adietish'
layout: blog_layout
tags: [OpenShift, Java]
---

At JBoss Tools we created a java client that allows you to talk to the [OpenShift](https://openshift.redhat.com/app/) PaaS: [openshift-java-client](https://github.com/openshift/openshift-java-client). The library is already used in the [OpenShift tooling](https://community.jboss.org/en/tools/blog/tags/openshift) in [JBoss Tools](http://www.jboss.org/tools/), the [Forge plugin](https://github.com/forge/plugin-openshift-express/) and [Appcelerator Titanium Studio](http://www.appcelerator.com/platform/titanium-studio)'s tooling for OpenShift. This blog post will show you how to use okthis API in your very own java programs. We'll develop a command line tool that displays informations equivalent to what you get when running **rhc domain show** with the [OpenShift command line tools](href="https://openshift.redhat.com/community/developers/install-the-client-tools): it displays basic informations about your user.


	================
	Namespace: andre
	  RHLogin: andre.dietisheim@redhat.com
	
	Application Info
	================
	kitchensink
	    Framework: jbossas-7
	     Creation: 2012-08-10T11:24:13-04:00
	         UUID: 8ad0d94f39aa4295a0049de8b8b5ef55
	      Git URL: ssh:<SOMEID>@kitchensink-andre.rhcloud.com/~/git/kitchensink.git/
	   Public URL: http://kitchensink-andre.rhcloud.com/
	
	 Embedded: 
	     jenkins-client-1.4 - Job URL: https://jenk-andre.rhcloud.com/job/kitchensink-build/
     


You'll find the sourcecode for this example at github: [https://github.com/adietish/show-domain-info] (https://github.com/adietish/show-domain-info). All the code that is shown in this blog is contained within the [Main](https://github.com/adietish/show-domain-info/blob/master/src/main/java/com/redhat/openshift/examples/domaininfo/Main.java) class.

If you want to dig futher, you'll get a more complete example that includes jenkins in [this wiki article](https://community.jboss.org/docs/DOC-19828).

# Openshift-java-client 2.0 #

The [openshift-java-client](https://github.com/openshift/openshift-java-client) is a java library that allows java programs to talk to the OpenShift PaaS. It talks to the new OpenShift [RESTful service](https://openshift.redhat.com/community/sites/default/files/documents/OpenShift-2.0-REST_API_Guide-en-US.pdf) and allows users to create, modify and destroy OpenShift resources: domains, applications, cartridges, etc. It is hosted on github at [https://github.com/openshift/openshift-java-client](https://github.com/openshift/openshift-java-client) and is available under the [Eclipse Public License](http://www.eclipse.org/legal/epl-v10.html).

**Note:**
Openshift-java-client 1.x was talking to the legacy service in OpenShift. 2.0 switched to the new RESTful service.
The legacy service is not maintained any more and will fade away at some point. Users of the 1.x client should migrate to the 2.0 client.
The migration should be pretty much without hassles. Even though 2.0 is a complete rewrite, the API stayed pretty much the same/very close.

# Requirements #


* You need an account on OpenShift. (If you have no account yet, you'd have to [signup](https://openshift.redhat.com/app/account/new) first)
* Make sure you have an OpenShift domain and some applications (to get some meaningful output)

# Launch Parameters #

To keep the implemenation simple, the program we're about to write, only accept 2 parameters on the command line:

1. username
1. password


Launching the program with maven would look like this:

	mvn test -Dusername=<username> -Dpassword=<password>

# Project Setup #

We have to make sure that we have the [openshift-java-client](https://github.com/openshift/openshift-java-client) available on our classpath. The client library is available at [https://github.com/openshift/openshift-java-client]("https://github.com/openshift/openshift-java-client). You could clone the repo and build your own jar by telling maven to "mvn clean package". But even simpler is to add it as dependency to your [pom.xml]("https://github.com/adietish/show-domain-info/blob/master/pom.xml#L8), since the client library is also available from central as maven artifact:

	<dependency>
	  <groupId>com.openshift</groupId>
	  <artifactId>openshift-java-client</artifactId>
	  <version>2.0.0</version>
	</dependency>


# Connect to OpenShift #

After we did some basic command line parameter parsing (that we skipped here on puropose) we'd have to get in touch with the OpenShift PaaS. Using the [openshift-java-client](https://github.com/openshift/openshift-java-client) you'd tell the [OpenShiftConnectionFactory](https://github.com/adietish/openshift-java-client/blob/master/src/main/java/com/openshift/client/OpenShiftConnectionFactory.java) to create a connection for you. To create this connection you'll have to provide some parameters:

### Server url ###

First of all you need to give it the url of the OpenShift PaaS. You may either hard code it or ask the OpenShift configuration for it:

	new OpenShiftConfiguration().getLibraServer()

The OpenShiftConfiguration class parses the OpenShift [configuration files](http://docs.redhat.com/docs/en-US/OpenShift/2.0/html/Getting_Started_Guide/sect-Getting_Started_Guide-OpenShift_Client_Tools-Configuring_Client_Tools.html) you may have on your machine (~/.openshift/express.conf, C:/Documents and Settings/user/.openshift/express.conf, etc.). Those usually get created once you installed the [rhc command line](http://docs.redhat.com/docs/en-US/OpenShift/2.0/html/User_Guide/chap-User_Guide-OpenShift_Command_Line_Interface.html) tools. In case you don't have any configuration yet, [OpenShiftConfiguration](href="https://github.com/adietish/openshift-java-client/blob/master/src/main/java/com/openshift/client/configuration/OpenShiftConfiguration.java) holds some meaningful [defaults](https://github.com/openshift/openshift-java-client/blob/master/src/main/java/com/openshift/client/configuration/DefaultConfiguration.java) and points to [http://openshift.redhat.com](http://openshift.redhat.com). On the other hand, our configuration class also allows you to override settings by putting them to the [system configuration](https://github.com/openshift/openshift-java-client/blob/master/src/main/java/com/openshift/client/configuration/SystemProperties.java) as you would do if you want to switch to the OpenShift [LiveCD](https://openshift.redhat.com/community/wiki/getting-started-with-openshift-origin-livecd) temporarly. You would then simply add the following to the command line when launching the java virtual machine:

	-Dlibra_server=127.0.0.1

### Client id ###

The connection factory also requires you to provide your very own client id. This client id is used when the openshift-java-client talks to the OpenShift REST service. It'll get included in the user-agent string that tells OpenShift what client it is talking to. We use the name of our example, **show-domain-info**.

### Username and Password ###

Last but not least, you also have to give it your OpenShift credentials, the ones we got from the command-line.

	String openshiftServer = new OpenShiftConfiguration().getLibraServer();
	IOpenShiftConnection connection = new OpenShiftConnectionFactory()
	  .getConnection("show-domain-info", "myuser", "mypassword", openshiftServer);


Once you have your connection you can get a [IUser](https://github.com/openshift/openshift-java-client/blob/master/src/main/java/com/openshift/client/IUser.java) instance which will allow you to create your domain and applications:

	IUser user = connection.getUser();

The first information block involves basic user informations. The username is available from your [IUser](https://github.com/adietish/openshift-java-client/blob/master/src/main/java/com/openshift/client/IUser.java) instance:

	System.out.println("RHLogin:\t" + user.getRhlogin());


The other value that we want to display, the domain namespace, is accessible from your OpenShift [IDomain](https://github.com/adietish/openshift-java-client/blob/master/src/main/java/com/openshift/client/IDomain.java). We'll get it from the the user instance and print its id (namespace).

	IDomain domain = user.getDefaultDomain();
	System.out.println("Namespace:\t" + domain.getId());

# Print the Application Infos #

The second portion printed by **rhc domain show** is reporting your users applications. All OpenShift applications are held in a list within your domain. We simply get the list and iterate over it's entries:

	for (IApplication application : domain.getApplications()) {


The required values - name, framework, creation time etc. - are now available within each [IApplication](https://github.com/adietish/openshift-java-client/blob/master/src/main/java/com/openshift/client/IApplication.java) instance:

	System.out.println(application.getName());
	System.out.println("\tFramework:\t" + application.getCartridge().getName());
	System.out.println("\tCreation:\t" + application.getCreationTime());
	System.out.println("\tUUID:\t\t" + application.getUUID());
	System.out.println("\tGit URL:\t" + application.getGitUrl());
	System.out.println("\tPublic URL:\t" + application.getApplicationUrl() + "\n");

An application may have several cartridges embedded (MySql, Postgres, Jenkins etc.). These cartridges are reported by by the application. We get the list of cartridges and inspect at each of them:

	for(IEmbeddedCartridge cartridge : application.getEmbeddedCartridges()) {

We then want to know bout a cartridge's [IEmbeddableCartridge](https://github.com/adietish/openshift-java-client/blob/master/src/main/java/com/openshift/client/IEmbeddedCartridge.java), name and url:

	System.out.println("\t" + cartridge.getName() + " - URL:" + cartridge.getUrl());


That is it - you now have an app that can talk to OpenShift via its [REST API](https://openshift.redhat.com/community/sites/default/files/documents/OpenShift-2.0-REST_API_Guide-en-US.pdf). If you want to do more we also have this [article](https://community.jboss.org/docs/DOC-19828) that shows how to perform actual operations against your OpenShift applications. 

Hope you enjoy it and let us know what you build with it!