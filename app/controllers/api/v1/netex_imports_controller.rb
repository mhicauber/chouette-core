module Api
  module V1
    class NetexImportsController < ActionController::Base
      include ControlFlow


      respond_to :json, :xml
      layout false

      def create
        respond_to do | format |
          format.json(&method(:create_models))
        end
      end


      private

      def find_workbench
        @workbench = Workbench.find(netex_import_params['workbench_id'])
      rescue ActiveRecord::RecordNotFound
        render json: {errors: {'workbench_id' => 'missing'}}, status: 406
        finish_action!
      end

      def create_models
        find_workbench
        create_netex_import
      end

      def create_netex_import
        attributes = netex_import_params.merge creator: "Webservice"
        @netex_import = Import::Netex.new attributes
        @netex_import.create_with_referential!
      rescue ActiveRecord::RecordInvalid
        render json: {errors: @netex_import.errors}, status: 406
        finish_action!
      end

      def netex_import_params
        params
          .require('netex_import')
          .permit(:file, :name, :workbench_id, :parent_id, :parent_type)
      end
    end
  end
end
