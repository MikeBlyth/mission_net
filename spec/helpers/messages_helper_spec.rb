include MessagesHelper

describe 'id tag helper (message_id_tag)' do
  # Of course these will have to be changed if you change the format of the tags
  let(:msg_id_string) {SiteSetting.message_id_string}
  
  it 'generates id_tag for body' do
    message_id_tag(:id=>500, :action=>:generate, :location=>:body).should == "#500"
  end
  
  it 'generates id_tag for head' do
    message_id_tag(:id=>500, :action=>:generate, :location=>:subject).should == "(#{msg_id_string} #500)"
  end

  it 'generates confirming tag for explanation (in body)' do
    message_id_tag(:id=>500, :action=>:confirm_tag).should == "!500"
  end
    
  it 'finds id_tag in subject' do
    message_id_tag(:action=>:find, :location=>:subject,
      :text => "Re: Important security message (#{msg_id_string} #501)").should == 501
  end
  
  it 'returns nil when finding id_tag in subject' do
    message_id_tag(:action=>:find, :location=>:subject,
      :text => "Re: Important security message ").should == nil
  end
  
  it 'finds id_tag in body (w "confirm #nnn")' do
    message_id_tag(:action=>:find, :location=>:body,
      :text => "lkj lkj l confirm #501").should == 501
  end
  
  it 'finds id_tag in body (w "!nnn")' do
    message_id_tag(:action=>:find, :location=>:body,
      :text => "lkj lkj l !501").should == 501
  end

  it 'returns nil when not finding id_tag in body' do
    message_id_tag(:action=>:find, :location=>:body,
      :text => "Re: Important security message ").should == nil
  end
end  
  
describe 'find_message_id_tag' do
  let(:msg_id_string) {SiteSetting.message_id_string}
  
  it 'finds tag in header' do
    find_message_id_tag(:subject=>"Re: Security (#{msg_id_string} #501)", :body => "Just some stuff").
      should == 501
  end

  it 'finds tag in body' do
    find_message_id_tag(:subject=>"Confirming", :body => "Just some stuff plus !501").should == 501
  end

  it 'returns nil if no tag anywhere' do
    find_message_id_tag(:subject=>"Confirming", :body => "Just some stuff ").should be_nil
  end
  
  it 'returns nil if no text is empty' do
    find_message_id_tag().should be_nil
  end
  
  it 'returns nil for exclamation point without following digits' do
    find_message_id_tag(:subject=>"Confirming", :body => "Just some stuff! ").should be_nil
  end
  
end # find_message_id_tag



