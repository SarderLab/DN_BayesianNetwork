%% Generating a Minimum Spanning Tree from nuclear centroid coordinates


P = coordinates;
D = zeros(length(P));
for a = 1:length(P)
    for b = 1:length(P)
        D(a, b) = ((P(1,a) - P(1,b))^2 + (P(2,a) - P(2,b))^2)^1/2;
    end
end
G = graph(D);
M = minspantree(G);

M_adj=adjacency(M);
G_adj=adjacency(G); 

%figure, mplot = plot(M);
mplot.XData = P(:, 2);
mplot.YData = 576-P(:, 1);
A = M.Edges;
sum(A.Weight)
mean(A.Weight)
%figure, histogram(M.Edges.Weight); title('Histogram of 2D MST Edge Lengths')
%figure, histogram(degree(M)); title('Histogram of 2D MST Node Degrees')