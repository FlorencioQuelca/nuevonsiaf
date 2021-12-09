module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user

      def obt_activos
        @activos = @user.assets
        respond_to do |format|
          format.json {
            if @activos.present?
              render json: @activos, each_serializer: AssetSerializer, root: false,
                     status: 200
            else
              render json: { mensaje: 'No tiene activos asignados.' },
                     status: 200
            end
          }
        end
      end

      def obt_historico_actas
        @actas =  @user.proceedings
        respond_to do |format|
          format.json {
            if @actas.present?
              render json: @actas, each_serializer: ProceedingSerializer, root: false,
                     status: 200
            else
              render json: { mensaje: 'No tiene histórico de activos que le fueron asignados.' },
                     status: 200
            end
          }
        end
      end

      private
        def set_user
          begin
            @user = User.find(params[:id])
          rescue ActiveRecord::RecordNotFound => e
            @user = nil
          end
        end
    end
  end
end
