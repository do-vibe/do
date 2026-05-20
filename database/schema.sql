


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."atoms" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "system_id" "uuid",
    "owner_id" "uuid",
    "task" "text" NOT NULL,
    "due_date" "date",
    "recurring" boolean DEFAULT false,
    "recurrence_rule" "text",
    "calendar_event_id" "text",
    "team_id" "uuid",
    "status" "text" DEFAULT 'pending'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "scheduled_start" time without time zone,
    "duration_minutes" integer DEFAULT 60,
    "ical_uid" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL,
    "sort_order" integer DEFAULT 0,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."atoms" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."goals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "uuid",
    "team_id" "uuid",
    "title" "text" NOT NULL,
    "purpose" "text",
    "category" "text",
    "status" "text" DEFAULT 'active'::"text",
    "due_date" "date",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."goals" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."retro_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "retro_id" "uuid",
    "item_type" "text",
    "item_id" "uuid",
    "note" "text"
);


ALTER TABLE "public"."retro_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."retros" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "uuid",
    "interval" "text",
    "reflection" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."retros" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."systems" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "goal_id" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."systems" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."team_members" (
    "team_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text"
);


ALTER TABLE "public"."team_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."teams" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."teams" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "google_id" "text",
    "email" "text" NOT NULL,
    "name" "text" NOT NULL,
    "display_name" "text",
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "calendar_token" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."atoms"
    ADD CONSTRAINT "atoms_ical_uid_key" UNIQUE ("ical_uid");



ALTER TABLE ONLY "public"."atoms"
    ADD CONSTRAINT "atoms_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."goals"
    ADD CONSTRAINT "goals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."retro_items"
    ADD CONSTRAINT "retro_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."retros"
    ADD CONSTRAINT "retros_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."systems"
    ADD CONSTRAINT "systems_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."team_members"
    ADD CONSTRAINT "team_members_pkey" PRIMARY KEY ("team_id", "user_id");



ALTER TABLE ONLY "public"."teams"
    ADD CONSTRAINT "teams_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_calendar_token_key" UNIQUE ("calendar_token");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_google_id_key" UNIQUE ("google_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."atoms"
    ADD CONSTRAINT "atoms_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."atoms"
    ADD CONSTRAINT "atoms_system_id_fkey" FOREIGN KEY ("system_id") REFERENCES "public"."systems"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."atoms"
    ADD CONSTRAINT "atoms_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id");



ALTER TABLE ONLY "public"."goals"
    ADD CONSTRAINT "goals_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."goals"
    ADD CONSTRAINT "goals_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id");



ALTER TABLE ONLY "public"."retro_items"
    ADD CONSTRAINT "retro_items_retro_id_fkey" FOREIGN KEY ("retro_id") REFERENCES "public"."retros"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."retros"
    ADD CONSTRAINT "retros_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."systems"
    ADD CONSTRAINT "systems_goal_id_fkey" FOREIGN KEY ("goal_id") REFERENCES "public"."goals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."team_members"
    ADD CONSTRAINT "team_members_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."team_members"
    ADD CONSTRAINT "team_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."teams"
    ADD CONSTRAINT "teams_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE "public"."atoms" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."goals" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."retro_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."retros" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."systems" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."team_members" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."teams" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON TABLE "public"."atoms" TO "anon";
GRANT ALL ON TABLE "public"."atoms" TO "authenticated";
GRANT ALL ON TABLE "public"."atoms" TO "service_role";



GRANT ALL ON TABLE "public"."goals" TO "anon";
GRANT ALL ON TABLE "public"."goals" TO "authenticated";
GRANT ALL ON TABLE "public"."goals" TO "service_role";



GRANT ALL ON TABLE "public"."retro_items" TO "anon";
GRANT ALL ON TABLE "public"."retro_items" TO "authenticated";
GRANT ALL ON TABLE "public"."retro_items" TO "service_role";



GRANT ALL ON TABLE "public"."retros" TO "anon";
GRANT ALL ON TABLE "public"."retros" TO "authenticated";
GRANT ALL ON TABLE "public"."retros" TO "service_role";



GRANT ALL ON TABLE "public"."systems" TO "anon";
GRANT ALL ON TABLE "public"."systems" TO "authenticated";
GRANT ALL ON TABLE "public"."systems" TO "service_role";



GRANT ALL ON TABLE "public"."team_members" TO "anon";
GRANT ALL ON TABLE "public"."team_members" TO "authenticated";
GRANT ALL ON TABLE "public"."team_members" TO "service_role";



GRANT ALL ON TABLE "public"."teams" TO "anon";
GRANT ALL ON TABLE "public"."teams" TO "authenticated";
GRANT ALL ON TABLE "public"."teams" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







