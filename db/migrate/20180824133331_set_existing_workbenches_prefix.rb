class SetExistingWorkbenchesPrefix < ActiveRecord::Migration
  def up
    Workbench.connection.execute 'UPDATE "public"."workbenches" SET prefix = organisations.code FROM "public"."organisations" WHERE "public"."organisations"."id" = "public"."workbenches"."organisation_id" AND "public"."workbenches"."prefix" IS NULL'
  end
end
