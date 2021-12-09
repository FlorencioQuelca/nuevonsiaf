module Api
  module V1
    class SuppliersController < ApplicationController
      before_action :set_supplier

      def show
        respond_to do |format|
          format.json do
            if @supplier.present?
               render json: @supplier,
                      role: current_user.role,
                      each_serializer: SupplierSerializer,
                      root: false,
                      status: 200
            else
              render json: { mensaje: 'No tiene activos asignados.' },
                     status: 404
            end
          end
        end
      end

      private

      def set_supplier
        @supplier = Supplier.find(params[:id])
      rescue ActiveRecord::RecordNotFound => _
        @supplier = nil
      end
    end
  end
end
