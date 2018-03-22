
function cmap = color_map(num)

cmap = zeros(num,3);
for i=1:num
    cmap(i,:) = rand(3,1);
end
end
