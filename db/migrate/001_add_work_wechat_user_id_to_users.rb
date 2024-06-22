class AddWorkWechatUserIdToUsers < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[6.1]
  def change
    add_column :users, :work_wechat_user_id, :string
  end
end
