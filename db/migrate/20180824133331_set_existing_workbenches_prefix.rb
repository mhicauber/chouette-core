class SetExistingWorkbenchesPrefix < ActiveRecord::Migration
  def up
    Workbench.connection.execute 'UPDATE "public"."workbenches" SET public.workbenches.prefix = organisations.code FROM "public"."workbenches" INNER JOIN "public"."organisations" ON "public"."organisations"."id" = "public"."workbenches"."organisation_id"  WHERE "public"."workbenches"."prefix" IS NULL'
  end
end
