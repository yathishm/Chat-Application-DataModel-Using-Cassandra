
/*
	creates a KEYSPACE "chat_application"
*/
CREATE KEYSPACE chat_application WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1};



/*
	creates a TABLE "chat_application.all_chat_messages_from_user_to_user" which stores all the private messages between two users
*/
CREATE TABLE chat_application.all_chat_messages_from_user_to_user (
    to_user bigint,
    from_user bigint,
    message_id text, // Timestamp with unique Id appended at the end, Example : "09-03-17 11:45:44.000000000 - 12345", 
    message text,
    message_received_at timestamp,
    message_status int,
    PRIMARY KEY ((to_user, from_user), message_id)
) WITH CLUSTERING ORDER BY (message_id DESC)
    AND additional_write_policy = '99p'
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND cdc = false
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '16', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND default_time_to_live = 0
    AND extensions = {}
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair = 'BLOCKING'
    AND speculative_retry = '99p';
    
    

/*
	creates a MATERIALIZED VIEW "chat_application.all_chat_messages_to_user" from the BASE TABLE "chat_application.all_chat_messages_from_user_to_user" which stores all the messages sent from multiple users to a user
*/
CREATE MATERIALIZED VIEW chat_application.all_chat_messages_to_user AS
    SELECT *
    FROM chat_application.all_chat_messages_from_user_to_user
    WHERE to_user IS NOT NULL AND from_user IS NOT NULL AND message_id IS NOT NULL AND message_status IS NOT NULL AND message_received_at IS NOT NULL
    PRIMARY KEY (to_user, message_status, from_user, message_id)
 WITH CLUSTERING ORDER BY (message_status DESC, from_user ASC, message_id DESC)
    AND additional_write_policy = '99p'
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND cdc = false
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '16', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND default_time_to_live = 0
    AND extensions = {}
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair = 'BLOCKING'
    AND speculative_retry = '99p';



/*
	creates a TABLE "chat_application.user_last_seen" which stores the user's last seen time
*/
CREATE TABLE chat_application.user_last_seen (
    user_id bigint PRIMARY KEY,
    last_seen_time timestamp
) WITH additional_write_policy = '99p'
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND cdc = false
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '16', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND default_time_to_live = 0
    AND extensions = {}
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair = 'BLOCKING'
    AND speculative_retry = '99p';
    
    

/*
	creates a TABLE "chat_application.group_messages" which stores all the group messages
*/
CREATE TABLE chat_application.group_messages (
    group_id bigint,
    message_id text,
    from_user bigint,
    message text,
    message_received_at timestamp,
    PRIMARY KEY (group_id, message_id)
) WITH CLUSTERING ORDER BY (message_id DESC)
    AND additional_write_policy = '99p'
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND cdc = false
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '16', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND default_time_to_live = 0
    AND extensions = {}
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair = 'BLOCKING'
    AND speculative_retry = '99p';

 
     
/*
	Query the table "all_chat_messages_from_user_to_user" to fetch all the messages sent from a user "A" to a user "B"
*/
SELECT * FROM chat_application.all_chat_messages_from_user_to_user WHERE to_user = 123 AND from_user = 456 ORDER BY message_id DESC;


/*
	Update the table "all_chat_messages_from_user_to_user" with the message status. Example : SENT (1) to DELIVERED (2) once the message is delivered to the user "123".
*/
UPDATE chat_application.all_chat_messages_from_user_to_user SET message_status = 2 WHERE to_user = 123 AND from_user = 456 AND message_id = '2017-07-01-123';


    
/*
	Query the Materialized View "all_chat_messages_to_user" to fetch all the UNREAD messages which are in SENT status to user "123".
*/    
SELECT * FROM chat_application.all_chat_messages_to_user WHERE to_user = 123 AND message_status = 1 ORDER BY message_status DESC, from_user ASC;



/*
	Query the table "user_last_seen" to fetch last seen time of a user, Example : User id = "123"
*/     
SELECT * FROM chat_application.user_last_seen WHERE user_id = 123;
    


    
