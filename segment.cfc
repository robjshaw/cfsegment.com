<cfcomponent name="segment" output="false" hint="integrate with segment.com">

	<cfscript>
		// https://segment.com/docs/spec/ for more info

		this.baseURL = 'https://api.segment.io/v1/';
		this.writeKey = 'Basic ' & ToBase64('your_api_key');
	</cfscript>


	<!--- public functions --->
	<cffunction name="identify" access="remote" returntype="struct" hint="https://segment.com/docs/spec/identify/">
		<cfargument name="userid" required="true" type="string" hint="https://segment.com/docs/spec/identify/##user-id" />
		<cfargument name="traits" required="false" type="struct" hint="https://segment.com/docs/spec/identify/##traits" />

		<cfscript>
			var payload = {};
			var result = {};

			payload['type'] = GetFunctionCalledName();
			payload['userId'] = arguments.userid;
			
			payload['traits'] = arguments.traits;

			result = call(payload['type'], payload);

			return result;
		</cfscript>

	</cffunction>

	<cffunction name="track" access="remote" returntype="struct" hint="https://segment.com/docs/track/">
		<cfargument name="userid" required="true" type="string" hint="https://segment.com/docs/spec/identify/##user-id" />
		<cfargument name="event" required="true" type="string" hint="event which occurred" />
		<cfargument name="event_properties" required="true" type="struct" hint="https://segment.com/docs/spec/track/##properties" />
		
		<cfscript>
			var payload = {};
			var result = {};

			payload['type'] = GetFunctionCalledName();
			payload['userId'] = arguments.userid;

			payload['event'] = arguments.event;

			payload['properties'] = arguments.event_properties;

			result = call(GetFunctionCalledName(), payload);

			return result;
		</cfscript>

	</cffunction>

	<!--- private functions --->
	<cffunction name="call" output="false" access="private" hint="makes rest call to segment.com">
		<cfargument name="resource" required="true" type="string" hint="name of public function which maps to rest resources" />
		<cfargument name="payload" required="true" type="struct" hint="body of http request to spec" />

		<cfscript>
			var result = {};
			var httpResult = '';

			var fullURL = this.baseURL & arguments.resource;
		</cfscript>

		<cfhttp url="#fullURL#" method="post" result="httpResult" timeout="10">
			<cfhttpparam type="header" name="Authorization" value="#this.writeKey#" />
			<cfhttpparam type="header" name="Content-Type" value="application/json" />
			<cfhttpparam type="body" value="#serializeJSON(arguments.payload)#" />
		</cfhttp>

		<cflog file="segment" text="resource:#arguments.resource#|httpStatusCode:#httpResult.Responseheader.Status_Code#" />

		<cfscript>
			if (isJson(httpResult.fileContent)) {
				result = deserializeJSON(httpResult.fileContent);
				result.httpStatusCode = httpResult.Responseheader.Status_Code;
			}

			return result;
		</cfscript>

	</cffunction>

</cfcomponent>