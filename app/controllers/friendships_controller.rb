class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @confirmed_friendships = current_user.confirmed_friendships
    @sent_requests = current_user.sent_requests
    @incoming_requests = current_user.incoming_requests
  end

  def create
    @users = User.all
    @reverse_friendship = Friendship.find_by(user_id: params[:friend_id], friend_id: current_user.id)
    if @reverse_friendship
      redirect_to friendships_path, alert: 'You already have an incoming request from this user.'
    else
      @friendship = current_user.sent_requests.build(friend_id: params[:friend_id], confirmed: false)
      if @friendship.save
        redirect_to user_path(id: params[:friend_id]), notice: 'Friend request sent.'
      else
        redirect_to users_path, alert: 'Request not sent. Something is wrong!'
      end
    end
  end

  def update
    # byebug
    @friendship = Friendship.find(params[:id])
    @friendship.confirmed = true

    if @friendship.save
      redirect_to friendships_path, notice: 'New friend added successfully!'
    else
      render index, flash.now[:error] = "Couldn't add friend :("
    end
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy
    if current_user.sent_invite?(@friendship.friend)
      redirect_to friendships_path, notice: 'Friendship request canceled.'
    elsif current_user.incoming_invite?(@friendship.user)
      redirect_to friendships_path, notice: 'Friend request rejected.'
    else
      redirect_to friendships_path, notice: 'Friend removed.'
    end
  end
end
