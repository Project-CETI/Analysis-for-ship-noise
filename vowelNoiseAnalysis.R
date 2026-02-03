library(lme4)
library(ggpubr)
library(effects)
library(dplyr)
library(performance)

vowelNoise <- read.csv("codasp_w_urn.csv") 

nrow(vowelNoise)
sum(nchar(vowelNoise$autovpkcodastr))


table(vowelNoise$mismatchN)

vowelNoise <-vowelNoise[vowelNoise$URN!=-1,]


table(vowelNoise$URN)
table(vowelNoise$mismatchN)




vowelNoise$URN<-factor(vowelNoise$URN)



vowelNoiseOne<-vowelNoise

vowelNoiseOne$mismatchN1<-ifelse(vowelNoiseOne$mismatchN==0,0,
                                 ifelse(vowelNoiseOne$mismatchN==1,0,
                                        1))



vowelNoiseOne$handvCat <- ifelse(vowelNoiseOne$handv=="a","a",
                                 ifelse(vowelNoiseOne$handv=="i","i","-1"))

vowelNoiseOne <- vowelNoiseOne[vowelNoiseOne$handvCat!="-1",]




vowelNoiseOneMod1 <- glmer(mismatchN1 ~ URN+handv + (1|whale), data = vowelNoiseOne, family = binomial)
vowelNoiseOneMod1Sum<-summary(vowelNoiseOneMod1)
vowelNoiseOneMod1Sum
coef(vowelNoiseOneMod1)
check_overdispersion(vowelNoiseOneMod1)

vowelNoiseOneMod2 <- glmer(mismatchN1 ~ 1 + (1|whale), data = vowelNoiseOne, family = binomial)
summary(vowelNoiseOneMod2)

AIC(vowelNoiseOneMod1,vowelNoiseOneMod2)

# Plot
vowelNoiseOneMod1.eff<-allEffects(vowelNoiseOneMod1)
vowelNoiseOneMod1.eff.df<-as.data.frame(vowelNoiseOneMod1.eff)

vowelNoiseOneMod1GG<-ggplot(vowelNoiseOneMod1.eff.df$URN,aes(x=URN, y=fit))+geom_point()+ geom_errorbar(aes(ymin=lower, ymax=upper), width=0.1)+xlab("URN") +ylab("More than one mismatched click")+ theme_bw() #+ggtitle("")#+ facet_grid(~feature)
vowelNoiseOneMod1GG

vowelNoiseOneMod1GGvowel<-ggplot(vowelNoiseOneMod1.eff.df$handv,aes(x=handv, y=fit))+geom_point()+ geom_errorbar(aes(ymin=lower, ymax=upper), width=0.1)+xlab("Coda vowel") +ylab("More than one mismatched click")+ theme_bw() #+ggtitle("")#+ facet_grid(~feature)
vowelNoiseOneMod1GGvowel

ggarrange(vowelNoiseOneMod1GG,vowelNoiseOneMod1GGvowel)

# Same results with Poisson regression if the dependent variable is the number of mismatched clicks

vowelNoiseOneMod1A <- glmer(mismatchN ~ URN+handv + (1|whale), data = vowelNoiseOne, family = poisson)
summary(vowelNoiseOneMod1A)
plot(allEffects(vowelNoiseOneMod1A),type="response")



#########



vowelNoise <- read.csv("codasp_w_urn.csv") 

vowelNoise <- vowelNoise[vowelNoise$URN!=-1,]

vowelNoise$handvCat <- ifelse(vowelNoise$handv=="a","a",
                              ifelse(vowelNoise$handv=="i","i","-1"))

vowelNoise <- vowelNoise[vowelNoise$handvCat!="-1",]

vowelNoise$handvCat<-factor(vowelNoise$handvCat)
vowelNoise$codatype<-factor(vowelNoise$codatype)



vowelNoise$numclick<-nchar(vowelNoise$autovpkcodastr)

vowelNoise$codatype<-factor(vowelNoise$codatype)

contrasts(vowelNoise$codatype)<-contr.treatment(levels(vowelNoise$codatype))




vowelNoiseMod1 <- glmer(URN ~ Duration+handvCat+(handvCat|whale), data = vowelNoise, family = binomial)
summary(vowelNoiseMod1)
AIC(vowelNoiseMod1)
plot(allEffects(vowelNoiseMod1),type="response")


table(vowelNoise[vowelNoise$handvCat=='i',]$URN)

count_df <- vowelNoise %>%
  filter(handvCat %in% c("a", "i")) %>%
  count(URN, handvCat)

vowelNoiseRaw <- ggplot(count_df,
                        aes(x = factor(URN), y = n, fill = handvCat)) +
  geom_col(position = "stack") +
  xlab("URN") +
  ylab("Count") +ggtitle("Raw Counts")+labs(fill = "Type")+
  theme_bw()




vowelNoiseMod1.eff<-allEffects(vowelNoiseMod1)
vowelNoiseModHandvcat.eff.df<-as.data.frame(vowelNoiseMod1.eff$handvCat)
vowelNoiseModDuration.eff.df<-as.data.frame(vowelNoiseMod1.eff$Duration)


vowelNoiseModHandvcatGG<-ggplot(vowelNoiseModHandvcat.eff.df,aes(x=handvCat, y=fit))+geom_point()+ geom_errorbar(aes(ymin=lower, ymax=upper), width=0.1)+xlab("Coda Vowel")+ylim(0,1) +ylab("URN")+ theme_bw() +ggtitle("Coda Vowels per URN")#+ facet_grid(~feature)

vowelNoiseModDurationGG<-ggplot(vowelNoiseModDuration.eff.df,aes(x=Duration, y=fit))+geom_line()+ geom_ribbon(aes(ymin=lower, ymax=upper), alpha=0.2)+xlab("Duration")+ylim(0,1) +ylab("URN")+ theme_bw() +ggtitle("Duration per URN")#+ facet_grid(~feature)

ggarrange(vowelNoiseRaw,vowelNoiseModHandvcatGG,vowelNoiseModDurationGG,nrow=1)


