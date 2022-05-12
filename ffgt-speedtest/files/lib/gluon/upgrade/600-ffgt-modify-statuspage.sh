#!/bin/sh
# Another ugly hack ...
# ... insert our WAN speedtest result into status-page.html, above the Traffic info

START=1

awk </rom/lib/gluon/status-page/view/status-page.html '/<h3><%:Traffic%><\/h3>/ {stopit=1;} {if(stopit!=1) print $0;}' >/lib/gluon/status-page/view/status-page.html
cat >>/lib/gluon/status-page/view/status-page.html <<EOF

				<%
					if unistd.access('/tmp/fbwanspeed.txt') then
						local wanspeed=util.readfile('/tmp/fbwanspeed.txt')
				%>
				<h3><%:WAN%></h3>
				<table>
				<% print(wanspeed) %>
				</table>
				<%- end %>

EOF
awk </rom/lib/gluon/status-page/view/status-page.html '/<h3><%:Traffic%><\/h3>/ {startit=1;} {if(startit==1) print $0;}' >>/lib/gluon/status-page/view/status-page.html
