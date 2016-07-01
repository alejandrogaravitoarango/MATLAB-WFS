function [] = Countdown()

cf = 1950;
sf = 22050;
d = 0.45;

for i = 1 : 3
    if i > 2
        d = d * 1.5;
    end
    n = sf * d;
    s = (1:n) / sf;
    s = sin(2 * pi * cf * s);
    sound(s, sf);
    pause(d + 0.35);
end

end