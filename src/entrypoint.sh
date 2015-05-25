#!/bin/sh -ex

if [ -f setup.done ] ; then
	exec /usr/bin/java -server -DopenfireHome=/openfire -Dopenfire.lib.dir=/openfire/lib -jar /openfire/lib/startup.jar
else 
	/usr/bin/java -server -DopenfireHome=/openfire -Dopenfire.lib.dir=/openfire/lib -jar /openfire/lib/startup.jar > openfire.log &
	while ! curl "http://localhost:9090/login.jsp" -H "Content-Type: application/x-www-form-urlencoded" --data "url="%"2Findex.jsp&login=true&username=admin&password=admin" -c cookies ; do
		echo "waiting for startup..."
		cat openfire.log || true
		sleep 1
	done
	{
		curl "http://localhost:9090/offline-messages.jsp?quota=100.00&strategy=2&update=Save+Settings" -b cookies
		curl "http://localhost:9090/user-create.jsp?username=sniper&name=&email=&password=sniper&passwordConfirm=sniper&create=Create+User" -b cookies 
		curl "http://localhost:9090/user-create.jsp?username=auction-item-54321&name=&email=&password=auction&passwordConfirm=auction&create=Create+User" -b cookies 
		curl "http://localhost:9090/user-create.jsp?username=auction-item-65432&name=&email=&password=auction&passwordConfirm=auction&create=Create+User" -b cookies 
	} > setup.log

	touch setup.done
	tail -f openfire.log
fi
