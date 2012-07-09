
class SentMessagesController < ApplicationController
  # GET /sent_messages
  # GET /sent_messages.json
  def index
    @sent_messages = SentMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sent_messages }
    end
  end

  # GET /sent_messages/1
  # GET /sent_messages/1.json
  def show
    @sent_message = SentMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sent_message }
    end
  end

  # GET /sent_messages/new
  # GET /sent_messages/new.json
  def new
    @sent_message = SentMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sent_message }
    end
  end

  # GET /sent_messages/1/edit
  def edit
    @sent_message = SentMessage.find(params[:id])
  end

  # POST /sent_messages
  # POST /sent_messages.json
  def create
    @sent_message = SentMessage.new(params[:sent_message])

    respond_to do |format|
      if @sent_message.save
        format.html { redirect_to @sent_message, notice: 'Sent message was successfully created.' }
        format.json { render json: @sent_message, status: :created, location: @sent_message }
      else
        format.html { render action: "new" }
        format.json { render json: @sent_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sent_messages/1
  # PUT /sent_messages/1.json
  def update
    @sent_message = SentMessage.find(params[:id])

    respond_to do |format|
      if @sent_message.update_attributes(params[:sent_message])
        format.html { redirect_to @sent_message, notice: 'Sent message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sent_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sent_messages/1
  # DELETE /sent_messages/1.json
  def destroy
    @sent_message = SentMessage.find(params[:id])
    @sent_message.destroy

    respond_to do |format|
      format.html { redirect_to sent_messages_url }
      format.json { head :no_content }
    end
  end
end
