module Api
  module V1
    class AccountsController < ApplicationController
      before_action :set_account

      def show
        respond_to do |format|
          format.json do
            if @account.present?
              render json: @account,
                     each_serializer: AccountSerializer,
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

      def set_account
        @account = Account.find(params[:id])
      rescue ActiveRecord::RecordNorFound => _
        @account = nil
      end
    end
  end
end
