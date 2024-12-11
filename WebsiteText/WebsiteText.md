### Intro
Building authorization into a software application can be time-consuming and tedious.  Creating authorization components youself can seem easy at first, but the time and effort required quickly adds up when you factor in error handling, data storage, performance tuning, application integration, etc.  But having robust authorization is also a core part of the security and integrity of our application, so can't be neglected.

ApplicationAccess is a fast, robust, and simple containerized, REST-based web application, providing a complete solution to authorization and permission management.

#### Simple
The ApplicationAccess data model avoids abstract and unnecessarily complex concepts like Principals, Claims, Subjects, etc... instead providing a simple and easy to inderstand interface and process.  You setup users and groups, and mappings to the elements you want those users and groups to have access to.  Then at runtime your application calls methods to answer simple questions like 'can user A access element X?', or 'which elements can user A access'.

#### Fast
The ApplicationAccess data model is stored in memory with changes to the database performed via a downstream process.  Hence queries can be serviced quickly without the overhead of backend disk, network, and service dependencies.  Query response time is typically sub-millisecond (excluding network latency).  ApplicationAccess preovides all the performance benefit of caching permissions locally without the drawbacks and risks of permission data becoming stale.

ApplicationAccess provides the performance benefits of local caching of permissions, but without the risks associated with cached data becoming stale.

#### Robust / Resilient
ApplicationAccess implements multiple techniques to ensure robust and reliable operation...
* Database Retries - When connected to Microsoft SQL Server, ApplicationAccess will retry when it encounters transient errors (e.g. network connection errors, database offline, etc...).  The number of retries and duration between retries is configurable.
* File Backup - In the case that writing to the database fails, ApplicationAccess can write any uncommitted events to the file system.  These events will be written to the database when ApplicationAccess is restarted.
* Configurable Behaviour - Behaviour in the case of serious but non-critical error is configurable.  For example if logging of metrics fails, ApplicationAccess can be configured to stop metric logging and continue running, or enter a 'fault state' and return a system error when receiving future queries.

#### Observable
ApplicationAccess can be configured to log detailed activity and performance metrics via the [ApplicationMetrics framework](https://github.com/alastairwyse/ApplicationMetrics).

#### Full Change History and Audit Trail
ApplicationAccess maintains a complete history of changes to the permissions it stores.  The database can be queried to show the exact state of the permissions at any historic point in time.

### Terminology
| Term | Description |
| ---- | ----------- |
| User | As the name suggests, a user of the system that ApplicationAccess manages the permissions for. |
| Group | A collection of users. |
| Application Components | A component of the system that ApplicationAccess manages the permissions for.  Application components can have access rights/permissions assigned to them.  In a GUI application a component could be a screen within that application. In an Web API application a component could be an endpoint of that API. |
| Access Levels | A level of access associated with a component.  Examples include 'view', 'modify', 'delete', 'add', etc... |
| Entities and Entity Types | Entities can be any type of data other (aside from application components) that user or group access rights/permissions can be assigned to.  One entity type could be 'clients' of a company which each entity being one of those clients.  Assigning rights/permissions to an entity would mean a user or group could access data regarding that client in the system.  Another entity type could be 'ProductLines' of a company, with each entity being a product line.  The naming is deliberately generic to allow entities to be used flexibly. |
| Elements | A general collective term for users, groups, application components, access levels, entity types, and entities. |
| Mapping | A general term for a relationship between elements.  For example, a 'user to group mapping' represents a user being a member of a group.  A 'group to entity mapping' would represent a group having access to an entity. |
| Events | Operations which change data in ApplicationAccess, e.g. adding a user, deleting a group, or adding a mapping between a user and an entity. |
| Queries | Operations which read/retrieve data from ApplicationAccess, e.g. getting a list of all users, or checking whether a mapping exists between a given user application component and access level. |
| Operations | A general collective term for events and queries. |



### Configuration and Setup

#### Downloading

The 'lite' version of ApplicationAccess is available as a docker image at the following location (**TODO link).

#### Environment Variables

The docker image requires setting the following environment variables...

| Variable Name | Required? | Possible Values | Description |
| ------------- | --------- | --------------- | ----------- |
| MODE | Yes | 'Launch' or 'EncodeConfiguration' | 'Launch' runs the container in the standard mode to act as a REST API service to manage authorization.  'EncodeConfiguration' is used to encode a JSON configuration file in the format required to pass to the 'ENCODED_JSON_CONFIGURATION' environment variable described below.  Running in 'EncodeConfiguration' mode stops the container after outputting the encoded configuration to the console/stdout |
| LISTEN_PORT | When MODE='Launch' | 0 - 65535 | The TCP port that ApplicationAccess should listen on |
| MINIMUM_LOG_LEVEL | When MODE='Launch' | 'Information', 'Warning', or 'Critical' | The minimum level of logs that should be output from ApplicationAccess (TODO hyperlink to logging section) |
| ENCODED_JSON_CONFIGURATION | When MODE='Launch' |  | Detailed JSON configuration for ApplicationAccess, having been encoded using the 'EncodeConfiguration' mode |
| CONFIGURATION_FILE_PATH | When MODE='EncodeConfiguration' |  | Full path to the ApplicationAccess JSON configuration file.  The directory in this path should be mapped to a physical volume in the container host (e.g. via the -v parameter in docker). |

These variables should be set through the -e parameter if running through docker, or the 'containers > env' section of a Kubernetes manifest file.



##### Log Levels

The log levels specified in the 'MINIMUM_LOG_LEVEL' variable correspond to the following types of logs...

| Log Level | Description |
| --------- | ----------- |
| Information | General information logs including details of each HTTP request received |
| Warning | Unexpected/anomalous events, e.g. non-fatal exceptions |
| Critical | Unexpected/anomalous events which prevent the continuing operation of ApplicationAccess |

#### Generating the 'ENCODED_JSON_CONFIGURATION' Variable

The below steps describe how to use the ApplicationAccess docker image to generate encoded configuration which is subsequently passed to a running ApplicationAccess instance via the 'ENCODED_JSON_CONFIGURATION' environment variable.

1. Download the ApplicationAccess docker container image...

```
docker image pull (TODO image path)
```

2. Save the JSON configuration to a file on the docker host machine, e.g. '/home/user/ApplicationAccessConfig.json'

3. Run the following docker command to start an instance of the ApplicationAccess container in 'encode configuration' mode.

```
docker run -it --rm -v /home/user/:/ext -e MODE=EncodeConfiguration -e CONFIGURATION_FILE_PATH=/ext/ApplicationAccessConfig.json (TODO image path)
```

The '/home/user' directory on the host machine (or directory where the JSON file to encode is located) is mapped to the '/ext' directory inside the container.  The container instance will write encoded configuration similar to the following to the console...

```
H4sIAAAAAAACA4ySwU7CQBCG7yS8A9kzmKIxJt4QIZiUWC3G89AOZWO7W2a3aCW8u7uU0m6CSntoMvPN35l/Ztft9HpsFEWo1BwEJEjhJn0EDUtQOJZCYKS5FOy+t7OogevkoszRhFkglU4Iwxef9Y9IUxcAQYYaSTUKBpiZGls7vL678sw7rEtb+jY/yvOUR2CVqh5b3JtCEkbccnnVgxoUJthiAlDqU1LsMHkdbLixzDIQ8YJnKAvbmVel9vazP3BsskWhH4rVCmmaFmrNRdJypUqE/Bt9nnErcevVdhxwX8r8SRgntpCa7I1nnpb6HDXxyJdJ4uo68YmAZYp2mhWkCvsOMwaNiaQyNJ3wLzsxc4GqxYCkNdL5y6n/Jhlqsnql1TlNhbGdwmTfJX0gLdaEEM/KJfHYqZftHZxzxmutGzcFFvicIx32fM6n/q9tToGnBeGoPlL2irogEZpyHuGbgK0BrGnsuFDXEvXPsV907hccvIMYayv32aCR+OMIj2dYX2O3s/8BAAD//w==
```

The encoded configuration can then be passed to an instance of the ApplicationAccess container via the 'ENCODED_JSON_CONFIGURATION' environment variable, when the container is run in 'Launch' mode.

#### Features and Settings

##### Swagger
Swagger documentation for all operation endpoints is available at this URL path...

```
/swagger/index.html
```

##### Health/Status API Endpoint
ApplicationAccess exposes a health/status API endpoint at the following URL path...

```
/api/v1/status
```

When ApplicationAccess is healty, calling this endpoint will return an HTTP 200 status, and JSON similar to the following

```
{ "startTime":"2024-11-28T07:30:00.4187477Z" }
```

If a critical, non-recoverable error has occurred (e.g. failure to write buffered events to the database), the endpoint will return an HTTP 500 status.  Note that the health/status endpoint is not available through the swagger page.

##### Event Buffering
The ApplicationAccess data model is stored in memory, with events which change the data model being buffered and periodically written to the database.  The frequency of writing to the database can be controlled through the 'EventBufferFlushing' section of the JSON configuration.  Parameter 'BufferSizeLimit' sets the number of events held in the buffer that will trigger a database write.  When this limit is reached all buffered events are written to the database.  Separately, parameter 'FlushLoopInterval' sets the interval between writes of buffered events to the database in milliseconds.  Hence this configuration...

```
"EventBufferFlushing": {
  "BufferSizeLimit": 50,
  "FlushLoopInterval": 30000
},
```

... will continuously write all buffered events to the database every 30 seconds, or when the number of buffered events reach 50, whichever occurs first.

##### Event Buffering Database Retries
When using SQL Server, ApplicationAccess will retry if it encounters a transient error (database offline, network errors, etc...) when attempting to write buffered events to the database.  The number of retries and interval between (in seconds) them can be configured through these parameters in the 'AccessManagerSqlDatabaseConnection.ConnectionParameters' section of the JSON configuration...

```
"RetryCount": 10,
"RetryInterval": 20,
```

If writing to the database fails after all retry attempts, ApplicationAccess will enter a 'fault state' and return an HTTP 500 status in response to any further operations, minimizing the potential for data loss.  It can also be configured to backup any unwritten events to a file (detailed below) when entering the fault state.

##### Event Backup File
ApplicationAccess can be optionally configured to, in the case of database write failure, store any events which failed to be written in a file.  On subsequent startup ApplicationAccess will read from this file and re-write the events to the database.  This behaviour can be configured through the 'EventPersistence' section of the JSON configuration.  The 'EventPersisterBackupFilePath' parameter should be set to the full path to the file used to store the events, e.g...

```
"EventPersistence": {
  "EventPersisterBackupFilePath": "/ext/ApplicationAccessEventBackup.json"
},
```

Additionally, the directory part of this path should be mapped to a physical volume in the container host, e.g. via the -v option in Docker, or the 'volumes' option in Kubernetes.  If using this feature in Kubernetes you need to ensure the mapped volume exists beyond the lifetime of the container instance (e.g. using [persistent volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) or similar).

##### Metrics
ApplicationAccess can be optionally configured to log detailed metrics on counts of events that occurred, time taken to process operations, state of internal components, etc.  Metric logging is performed via the [ApplicationMetrics framework](https://github.com/alastairwyse/ApplicationMetrics), which can be configured to write the metrics to Microsoft SQL Server or PostgreSQL.  Metrics logging is configured via the 'MetricLogging' section of the JSON configuration.  Similarly to the processing of core events in ApplicationAccess, metrics are buffered and writen to the database periodically.  The 'MetricBufferProcessing' section of the metrics JSON configuration allows specifying the buffer size and frequency that metrics are written to the database.  For example to specify a maximum number of 500 metrics to be buffered, and writes to the database every 30 seconds the following JSON configuration should be used...

```
"BufferProcessingStrategy": "SizeLimitedLoopingWorkerThreadHybridBufferProcessor",
"BufferSizeLimit": 500,
"DequeueOperationLoopInterval": 30000,
```

The options available for the 'BufferProcessingStrategy' parameter are detailed in the [ApplicationMetrics documentation](https://github.com/alastairwyse/ApplicationMetrics?tab=readme-ov-file#3-choosing-a-buffer-processing-strategy).

**Note** that the parameters in the 'MetricBufferProcessing' section of the JSON configuration must be provided even if the 'MetricLoggingEnabled' parameter is set to 'false'.  See the 'JSON Configuration Example' section for examples of minimal configuration with metric logging disabled (TODO links to these sections).

##### Metrics Failure Handling
If writing of metrics to the database fails, ApplicationAccess can be configured to bahave as follows via the 'BufferProcessingFailureAction' parameter...

| Parameter Value | Behaviour |
| --------------- | --------- |
| ReturnServiceUnavailable | ApplicationAccess will enter a 'fault state', and return an HTTP 500 status in response to any further operations.  The metrics database error would need to be resolved, and ApplicationAccess restarted in order to rectify the issue. |
| DisableMetricLogging | Disable further logging of mertrics, but continue to respond to operations as normal.  Whilst option this stops further attempts to write metrics to the database, metrics will still be buffered and will consume memory. The metrics database error would need to be resolved, and ApplicationAccess restarted in order to return to normal operation. |

**Note** that if 'DisableMetricLogging' option is used, once a failure to write metrics has occurred, metrics will accumulate in the buffers which will eventually lead to out of memory errors.  When such a failure occurs, the following message will be logged (TODO link to logging section)...

```
Metric logging has been disabled due to an unrecoverable error whilst processing the metrics buffer(s).
```

The logs should be monitored for such a message, and if encountered the database error should be resolved and ApplicationAccess restarted. 

##### CORS
ApplicationAccess allows configuring valid [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) origins via the optional 'Cors' section of the JSON configuration.  For example...

```
"Cors": {
  "AllowedOrigins": [ "http://localhost:4200", "http://www.contoso.com" ]
}
```

##### Logging
ApplicationAccess writes logging information to stdout by default.  The level of detail can be configured via the 'MINIMUM_LOG_LEVEL' environment variable (TODO link to section above).  In addition, logs can optionally be written to a file.  The location of the file can be configured in the 'FileLogging' section of the JSON configuration, e.g...

```
"FileLogging": {
  "LogFilePath": "/ext",
  "LogFileNamePrefix": "ApplicationAccessLog"
}
```

Note that the 'LogFilePath' should be a path which is mapped to a physical volume in the docker host, similar to the 'EventPersisterBackupFilePath' configuration (TODO link to that).  Log file sizes are limited to 1GB per calendar day, and logging will stop when 1GB is reached.

**Note** that by default, logs written to stdout use ANSI colour codes.  To disable this, add the following section to the JSON configuration...

```
"Logging": {
  "Console": {
    "DisableColors": true
  }
}
```

##### Error Handling
ApplicationAccess returns errors following [HTTP status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) conventions, and detailing the reason/cause of the error in a standardized JSON format.  For example...

```
{
  "error": {
    "code": "NotFoundException",
    "message": "User 'User1' does not exist.",
    "target": "ContainsUser",
    "attributes": [
      {
        "name": "ResourceId",
        "value": "User1"
      }
    ]
  }
}
```

Additional detail can by included in the JSON error by setting the 'IncludeInnerExceptions' parameter in the 'ErrorHandling' section of the JSON configuration to 'true', e.g...

```
"ErrorHandling": {
  "IncludeInnerExceptions": true
}
```
    
This will result in the internal exception stack being returned in nested 'innererror' JSON properties like below...

```
{
  "error": {
    "code": "UserNotFoundException",
    "message": "User 'User1' does not exist. (Parameter 'user')",
    "target": "ThrowUserDoesntExistException",
    "attributes": [
      {
        "name": "ParameterName",
        "value": "user"
      },
      {
        "name": "User",
        "value": "User1"
      }
    ],
    "innererror": {
      "code": "LeafVertexNotFoundException`1",
      "message": "Vertex 'User1' does not exist in the graph.",
      "target": "ThrowExceptionIfLeafVertexDoesntExistInGraph"
    }
  }
}
```

This feature may be useful if ApplicationAccess errors need to be interpretted and handled programmatically.

If ApplicationAccess encounters a critical error (typically failure to write to a database), it will return an HTTP 500 status in response to any further operations, in order to minimize the potential for data loss.  The JSON error returned in this case will be...

```
{
  "error": {
    "code": "ServiceUnavailableException",
    "message": "The service is unavailable due to an interal error.",
    "target": "MoveNext"
  }
}
```

...however full details of the underlying error will be available in the logs (TODO link to logging section).

#### Database Setup
ApplicationAccess supports Microsoft SQL Server or PostgreSQL as its database.

##### Creating the Database
Scripts to create the database schema can be downloaded from these locations...

(TODO Update both scripts to company github)

| Platform | Script Location |
| -------- | --------------- |
| SQL Server | https://github.com/alastairwyse/ApplicationAccess/blob/main/ApplicationAccess.Persistence.Sql.SqlServer/Resources/CreateDatabase.sql | 
| PostgreSQL | https://github.com/alastairwyse/ApplicationAccess/blob/main/ApplicationAccess.Persistence.Sql.PostgreSql/Resources/CreateDatabase.sql |

By default these scripts create databases named 'ApplicationAccess'.  If required, this name can be changed by updating the scripts, and adjusting the connection configuration accordingly.  Note that in PostgreSQL, the creation of the database and schema objects may need to be executed as separate steps, logging out and back into the database under the 'ApplicationAccess' database context before creating the schema objects.

##### Database Configuration
Connection to the database is configured through the 'AccessManagerSqlDatabaseConnection' section of the JSON configuration.  The 'DatabaseType' parameter should be set to 'SqlServer' or 'PostgreSQL' depending on the platform used.  Then the connection settings are specified in the 'ConnectionParameters' section.  This section can be configured either by specifying values for the specific connection parameters ('DataSource', 'InitialCatalog', 'Host', 'Database', etc... parameter names vary depnding on the platform), or by specifying a single 'ConnectionString' parameter.  In addition values are required for timeout and retry-specific parameters ('CommandTimeout', 'RetryCount', 'RetryInterval', and 'OperationTimeout', depending on the platform).  See the 'JSON Configuration Example' and 'JSON Configuration Reference' section for examples of database configuration (TODO links to these sections).

##### Metrics Database Configuration
The connection to the database used for metric logging is configured in the 'MetricsSqlDatabaseConnection' section of the JSON configuration.  Metrics can also be written to SQL Server or PostgreSQL, and the JSON structure of the 'MetricsSqlDatabaseConnection' matches that of the 'AccessManagerSqlDatabaseConnection' section.  Scripts to create the metrics database are available in the relevant ApplicationMetrics 'MetricLogger' projects on Github...

| Platform | Project Location |
| -------- | ---------------- |
| SQL Server | https://github.com/alastairwyse/ApplicationMetrics.MetricLoggers.SqlServer | 
| PostgreSQL | https://github.com/alastairwyse/ApplicationMetrics.MetricLoggers.PostgreSql |

**Note** that the parameters in the 'MetricsSqlDatabaseConnection' section of the JSON configuration must be provided even if the 'MetricLoggingEnabled' parameter is set to 'false'.  See the 'JSON Configuration Example' section for examples of minimal configuration with metric logging disabled (TODO links to these sections).

##### Database Licensing
Microsoft SQL Server requires a license for non-development use.  Please ensure you use it within the terms of the license.

#### Kubernetes Setup
If hosting ApplicationAccess in Kubernetes, please ensure the following Kubernetes configuration is observed...

**Pod Replicas** - An ApplicationAccess instance requires exclusive access to its database.  Hence the 'replicas' configuration in the ApplicationAccess pod must be set to 1.
**Container Lifecycle Hooks** - On shutdown ApplicationAccess writes any buffered events to the database.  In the case that the buffers hold a large number of events (e.g. in the case of a 'flood' of events which exceed the database's write throughput), it could take some time to write these events to the database.  Hence it's recommeded to set the 'terminationGracePeriodSeconds' parameter to a sufficiently high value to allow these events to be processed and prevent loss of data (e.g. 3600 seconds = 1 hour).  This will prevent Kubernetes from killing the ApplicationAccess instance before processing of the buffer has completed.  The ApplicationAccess instance will terminate gracefully once the buffered events have been written to the database.
**Liveness, Readiness and Startup Probes** - ApplicationAccess exposes a health/status API endpoint (TODO link to doco on that), however this endpoint is not available (i.e. will not respond) whilst buffered events are written to the database during shutdown.  Be wary of this if using the health/status endpoint in Kubernetes liveness, readiness or startup probes... e.g. if the health/status endpoint is used for the Liveness probe, the endpoint would not respond whilst writing a large number of buffered events during a graceful shutdown, which could result in an unintended forced restart (and potential loss of the buffered events).

#### Minimal JSON Configuration Example

```
{
  "AccessManagerSqlDatabaseConnection": {
    "DatabaseType": "PostgreSQL",
    "ConnectionParameters": {
      "Host": "127.0.0.1",
      "Database": "ApplicationAccess",
      "Username": "postgres-user",
      "Password": "postgres-password",
      "CommandTimeout": 0
    }
  },
  "EventBufferFlushing": {
    "BufferSizeLimit": 50,
    "FlushLoopInterval": 30000
  },
  "MetricLogging": {
    "MetricLoggingEnabled": false,
    "MetricCategorySuffix": "",
    "MetricBufferProcessing": {
      "BufferProcessingStrategy": "SizeLimitedLoopingWorkerThreadHybridBufferProcessor",
      "BufferSizeLimit": 500,
      "DequeueOperationLoopInterval": 30000,
      "BufferProcessingFailureAction": "ReturnServiceUnavailable"
    },
    "MetricsSqlDatabaseConnection": {
      "DatabaseType": "PostgreSQL",
      "ConnectionParameters": {
        "ConnectionString": "-",
        "CommandTimeout": 0
      }
    }
  }
}
```

#### Full JSON Configuration Example

```
{
  "AccessManagerSqlDatabaseConnection": {
    "DatabaseType": "SqlServer",
    "ConnectionParameters": {
      "DataSource": "127.0.0.1",
      "InitialCatalog": "ApplicationAccess",
      "UserId": "sqlserver-user",
      "Password": "sqlserver-password",
      "RetryCount": 10,
      "RetryInterval": 20,
      "OperationTimeout": 0
    }
  },
  "EventBufferFlushing": {
    "BufferSizeLimit": 50,
    "FlushLoopInterval": 30000
  },
  "EventPersistence": {
    "EventPersisterBackupFilePath": "/ext/ApplicationAccessEventBackup.json"
  },
  "MetricLogging": {
    "MetricLoggingEnabled": true,
    "MetricCategorySuffix": "",
    "MetricBufferProcessing": {
      "BufferProcessingStrategy": "SizeLimitedLoopingWorkerThreadHybridBufferProcessor",
      "BufferSizeLimit": 500,
      "DequeueOperationLoopInterval": 30000,
      "BufferProcessingFailureAction": "ReturnServiceUnavailable"
    },
    "MetricsSqlDatabaseConnection": {
      "DatabaseType": "SqlServer",
      "ConnectionParameters": {
        "ConnectionString": "Server=127.0.0.1;Database=ApplicationMetrics;User Id=metrics-user;Password=metrics-password;Encrypt=false;Authentication=SqlPassword",
        "RetryCount": 10,
        "RetryInterval": 20,
        "OperationTimeout": 0
      }
    }
  }, 
  "Cors": {
    "AllowedOrigins": [ "http://localhost:4200", "http://www.contoso.com" ]
  },
  "FileLogging": {
    "LogFilePath": "/ext",
    "LogFileNamePrefix": "ApplicationAccessLog"
  }, 
  "ErrorHandling": {
    "IncludeInnerExceptions": false
  }, 
  "Logging": {
    "Console": {
      "DisableColors": true
    }
  }
}
```

#### JSON Configuration Reference

The table below describes the contents of the ApplicationAccess JSON configuration file...

TODO: Possible note about optionality of granular DB params vs connection string
TODO: Something about dummy metrics values being required
TODO: Could leave blank parts in the table to denote hierarchy... might be easier to read

| JSON Path | Required? | Possible Values | Description |
| --------- | --------- | --------------- | ----------- |
| AccessManagerSqlDatabaseConnection.DatabaseType | Yes | 'SqlServer' or 'PostgreSQL' | The type of the database ApplicationAccess should use |
| AccessManagerSqlDatabaseConnection.ConnectionParameters.DataSource | When DatabaseType='SqlServer' |  | The hostname or IP address of the SQL Server instance | 
| AccessManagerSqlDatabaseConnection.ConnectionParameters.InitialCatalog | When DatabaseType='SqlServer' |  | The name of the database to connect to within the SQL Server instance | 
| AccessManagerSqlDatabaseConnection.ConnectionParameters.UserId | When DatabaseType='SqlServer' |  | The user id to use to connect | 
| AccessManagerSqlDatabaseConnection.ConnectionParameters.Password | Yes |  | The password to use to connect | 
| AccessManagerSqlDatabaseConnection.ConnectionParameters.ConnectionString | When detailed connection parameters ('DataSource', 'InitialCatalog', 'Host', etc...) are not specified |  | The connection string to use to connect.  Can be specified for [SqlServer](https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/connection-string-syntax) or [PostgreSQL](https://www.npgsql.org/doc/connection-string-parameters.html.) | 
| AccessManagerSqlDatabaseConnection.ConnectionParameters.RetryCount | When DatabaseType='SqlServer' | 0 - 59 | The number of times a database operation should be retried if a transient error is encountered. |
| AccessManagerSqlDatabaseConnection.ConnectionParameters.RetryInterval | When DatabaseType='SqlServer' | 0 - 120 | The time to wait (in seconds) between retries. |
| AccessManagerSqlDatabaseConnection.ConnectionParameters.OperationTimeout | When DatabaseType='SqlServer' | 0 - 2147483647 | The time to wait (in seconds) before terminating a database operation and generating an error.  A value of 0 will wait indefinitely. |
| AccessManagerSqlDatabaseConnection.ConnectionParameters.Host | When DatabaseType='PostgreSQL' |  | The hostname or IP address of the PostgreSQL instance |
| AccessManagerSqlDatabaseConnection.ConnectionParameters.Database | When DatabaseType='PostgreSQL' |  | The name of the database to connect to within the PostgreSQL instance |
| AccessManagerSqlDatabaseConnection.ConnectionParameters.Username | When DatabaseType='PostgreSQL' |  | The user id to use to connect |
| AccessManagerSqlDatabaseConnection.ConnectionParameters.CommandTimeout | When DatabaseType='PostgreSQL' | 0 - 2147483647 | The time to wait (in seconds) before terminating a database operation and generating an error.  A value of 0 will wait indefinitely. |
| EventBufferFlushing.BufferSizeLimit | Yes | 1 - 2147483647 | The number of events to store in the buffer before triggering a write to the database. | 
| EventBufferFlushing.FlushLoopInterval | Yes | 1 - 2147483647 | The time (in milliseconds) between writes of the buffer to the database. |
| EventPersistence.EventPersisterBackupFilePath | No |  | An optional full path to a file to use to backup the buffer contents, in the case of a failure to write to the database. |
| MetricLogging.MetricLoggingEnabled | Yes | 'true' or 'false' | Whether to log metrics |
| MetricLogging.MetricCategorySuffix | Yes | Blank string or suffix | An optional suffix to concatenate to the category used to log metrics under.  E.g. If multiple ApplicationAccess instances wrote metrics to the same database, this suffix could be used to differentiate the metrics for each instance.  JSON property must be specified, but value can be a blank string. |
| MetricLogging.MetricBufferProcessing.BufferProcessingStrategy | Yes | 'SizeLimitedBufferProcessor', 'LoopingWorkerThreadBufferProcessor', or 'SizeLimitedLoopingWorkerThreadHybridBufferProcessor' | The [metrics buffer processing strategy](https://github.com/alastairwyse/ApplicationMetrics?tab=readme-ov-file#3-choosing-a-buffer-processing-strategy) to use |
| MetricLogging.MetricBufferProcessing.BufferSizeLimit | Yes | 1 - 2147483647 | The number of metric events to store in the buffer before triggering a write to storage. |
| MetricLogging.MetricBufferProcessing.DequeueOperationLoopInterval | Yes | 1 - 2147483647 | The time (in milliseconds) between writes of the metric buffer to storage. |
| MetricLogging.MetricBufferProcessing.BufferProcessingFailureAction | Yes | 'ReturnServiceUnavailable' or 'DisableMetricLogging' | The action ApplicationAccess should take when processing of the metric buffer fails (e.g. due to a failure to write to the database). TODO link to detailed doco |
| MetricLogging.MetricsSqlDatabaseConnection.DatabaseType | Yes | 'SqlServer' or 'PostgreSQL' | The type of the database ApplicationAccess should connect to for metric logging |
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.DataSource | When DatabaseType='SqlServer' |  | The hostname or IP address of the SQL Server instance used for metric logging | 
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.InitialCatalog | When DatabaseType='SqlServer' |  | The name of the database to connect to within the SQL Server instance | 
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.UserId | When DatabaseType='SqlServer' |  | The user id to use to connect | 
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.Password | Yes |  | The password to use to connect | 
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.ConnectionString | When detailed connection parameters ('DataSource', 'InitialCatalog', 'Host', etc...) are not specified |  | The connection string to use to connect.  Can be specified for [SqlServer](https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/connection-string-syntax) or [PostgreSQL](https://www.npgsql.org/doc/connection-string-parameters.html.) | 
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.RetryCount | When DatabaseType='SqlServer' | 0 - 59 | The number of times a metrics database operation should be retried if a transient error is encountered. |
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.RetryInterval | When DatabaseType='SqlServer' | 0 - 120 | The time to wait (in seconds) between retries. |
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.OperationTimeout | When DatabaseType='SqlServer' | 0 - 2147483647 | The time to wait (in seconds) before terminating a database operation and generating an error.  A value of 0 will wait indefinitely. |
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.Host | When DatabaseType='PostgreSQL' |  | The hostname or IP address of the PostgreSQL instance used for metric logging |
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.Database | When DatabaseType='PostgreSQL' | The name of the database to connect to within the PostgreSQL instance |  |
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.Username | When DatabaseType='PostgreSQL' |  | The user id to use to connect |
| MetricLogging.MetricsSqlDatabaseConnection.ConnectionParameters.CommandTimeout | When DatabaseType='PostgreSQL' | 0 - 2147483647 | The time to wait (in seconds) before terminating a database operation and generating an error.  A value of 0 will wait indefinitely. |
| Cors.AllowedOrigins | No |  | A list (JSON array of strings) of [CORS origins](https://developer.mozilla.org/en-US/docs/Glossary/Origin) (domain, scheme, port) which ApplicationAccess should return in the 'Access-Control-Allow-Origin' header of any HTTP responses |
| FileLogging.LogFilePath | No |  | The path to optionally write log files to (not including the file name).  This folder should typically be mapped to a physical volume in the container host (e.g. via the -v parameter in docker). |
| FileLogging.LogFileNamePrefix | No |  | The prefix to include in log files names.  Log files are named (or postfixed if the prefix is defined) with the day of the logs in YYYMMDD format, and have a '.log' extension. |
| ErrorHandling.IncludeInnerExceptions | No | 'true' or 'false' | Whether additional detail (inner exception information) is included in JSON error responses returned by ApplicationAccess. TODO link to error handling |

#### Troubleshooting
**'Value for parameter 'encodedJsonConfiguration' could not be decoded' when starting ApplicationAccess**
This error can occur if the JSON in the 'ENCODED_JSON_CONFIGURATION' environment variable is invalid (e.g. missing comma, quotation, etc...).  Ensure the configuration contains valid JSON.

TODO:
Maybe mark all 'required' 'Yes' values for metrics logging with a * or similar, and have a caveat/footnote at the bottom
Maybe as 'step by step' section
Buffer config isn't it limit, it's a trigger point... correct the wording here... misleading for the reader
Step by step user setup from github repo front page
Info about Java, Python clients