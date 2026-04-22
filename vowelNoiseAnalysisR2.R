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


vowelNoiseOneMod1a <- glmer(mismatchN1 ~ URN+handv + (URN|whale), data = vowelNoiseOne, family = binomial)
vowelNoiseOneMod1 <- glmer(mismatchN1 ~ URN+handv + (1|whale), data = vowelNoiseOne, family = binomial)
AIC(vowelNoiseOneMod1a,vowelNoiseOneMod1)
anova(vowelNoiseOneMod1a,vowelNoiseOneMod1)

vowelNoiseOneMod1 <- glmer(mismatchN1 ~ URN+handv + (1|whale), data = vowelNoiseOne, family = binomial)
vowelNoiseOneMod1Sum<-summary(vowelNoiseOneMod1)
vowelNoiseOneMod1Sum
coef(vowelNoiseOneMod1)
check_overdispersion(vowelNoiseOneMod1)

vowelNoiseOneMod2 <- glmer(mismatchN1 ~ 1 + (1|whale), data = vowelNoiseOne, family = binomial)
summary(vowelNoiseOneMod2)

AIC(vowelNoiseOneMod1,vowelNoiseOneMod2)
anova(vowelNoiseOneMod1,vowelNoiseOneMod2)

# Plot
vowelNoiseOneMod1.eff<-allEffects(vowelNoiseOneMod1)
vowelNoiseOneMod1.eff.df<-as.data.frame(vowelNoiseOneMod1.eff)

vowelNoiseOneMod1GG<-ggplot(vowelNoiseOneMod1.eff.df$URN,aes(x=URN, y=fit))+geom_point()+ geom_errorbar(aes(ymin=lower, ymax=upper), width=0.1)+xlab("URN") +ylab("More than one mismatched click")+ theme_bw() 
vowelNoiseOneMod1GG

vowelNoiseOneMod1GGvowel<-ggplot(vowelNoiseOneMod1.eff.df$handv,aes(x=handv, y=fit))+geom_point()+ geom_errorbar(aes(ymin=lower, ymax=upper), width=0.1)+xlab("Coda Quality") +ylab("More than one mismatched click")+ theme_bw() 
vowelNoiseOneMod1GGvowel

ggarrange(vowelNoiseOneMod1GG,vowelNoiseOneMod1GGvowel)


# Same results with Poisson regression if the dependent variable is the number of mismatched clicks

vowelNoiseOneMod1A <- glmer(mismatchN ~ URN+handv + (URN|whale), data = vowelNoiseOne, family = poisson)
coef(vowelNoiseOneMod1A)
summary(vowelNoiseOneMod1A)
plot(allEffects(vowelNoiseOneMod1A),type="response")
check_overdispersion(vowelNoiseOneMod1A)




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
check_overdispersion(vowelNoiseMod1)

table(vowelNoise[vowelNoise$handvCat=='i',]$URN)

count_df <- vowelNoise %>%
  filter(handvCat %in% c("a", "i")) %>%
  count(URN, handvCat)

vowelNoiseRaw <- ggplot(count_df,
                        aes(x = factor(URN), y = n, fill = handvCat)) +
  geom_col(position = "stack") +
  xlab("URN") +
  ylab("Count") +ggtitle("Raw Counts (All Types)")+labs(fill = "Type")+
  theme_bw()




vowelNoiseMod1.eff<-allEffects(vowelNoiseMod1)
vowelNoiseModHandvcat.eff.df<-as.data.frame(vowelNoiseMod1.eff$handvCat)
vowelNoiseModDuration.eff.df<-as.data.frame(vowelNoiseMod1.eff$Duration)


vowelNoiseModHandvcatGG<-ggplot(vowelNoiseModHandvcat.eff.df,aes(x=handvCat, y=fit))+geom_point()+ geom_errorbar(aes(ymin=lower, ymax=upper), width=0.1)+xlab("Coda Quality")+ylim(0,1) +ylab("URN")+ theme_bw() +ggtitle("Coda Quality (All Types)")#+ facet_grid(~feature)

vowelNoiseModDurationGG<-ggplot(vowelNoiseModDuration.eff.df,aes(x=Duration, y=fit))+geom_line()+ geom_ribbon(aes(ymin=lower, ymax=upper), alpha=0.2)+xlab("Duration")+ylim(0,1) +ylab("URN")+ theme_bw() +ggtitle("Duration (All Types)")#+ facet_grid(~feature)

ggarrange(vowelNoiseRaw,vowelNoiseModHandvcatGG,vowelNoiseModDurationGG,nrow=1)

table(vowelNoise$codatype)
nrow(vowelNoise)
702/nrow(vowelNoise)




# Only 1+1+3

vowelNoise113 <- vowelNoise[vowelNoise$codatype=="1+1+3",]
vowelNoise113$Duration<-as.numeric(scale(vowelNoise113$Duration,center=TRUE, scale = FALSE))
vowelNoise113$URN<-as.factor(vowelNoise113$URN)

vowelNoise113$handvCat1<-ifelse(vowelNoise113$handvCat=="i",1,0)


vowelNoise113Mod1a <- glmer(handvCat~ URN*Duration+(URN|whale), data = vowelNoise113, family = binomial)
vowelNoise113Mod1b <- glmer(handvCat~ URN*Duration+(1|whale), data = vowelNoise113, family = binomial)

AIC(vowelNoise113Mod1a,vowelNoise113Mod1b)
anova(vowelNoise113Mod1a,vowelNoise113Mod1b)

vowelNoise113Mod1c <- glmer(handvCat~ URN*Duration+(1|whale), data = vowelNoise113, family = binomial)
vowelNoise113Mod1d <- glmer(handvCat~ URN+Duration+(1|whale), data = vowelNoise113, family = binomial)

AIC(vowelNoise113Mod1c,vowelNoise113Mod1d)
anova(vowelNoise113Mod1c,vowelNoise113Mod1d)


vowelNoise113Mod1 <- glmer(handvCat~ URN*Duration+(URN|whale), data = vowelNoise113, family = binomial)
summary(vowelNoise113Mod1)
AIC(vowelNoise113Mod1)
plot(allEffects(vowelNoise113Mod1),type="response")
check_overdispersion(vowelNoise113Mod1)

vowelNoise113Mod1d <- glmer(handvCat1~ URN+Duration+(1|whale), data = vowelNoise113, family = binomial)
summary(vowelNoise113Mod1d)
plot(allEffects(vowelNoise113Mod1d))
check_overdispersion(vowelNoise113Mod1d)



count_df <- vowelNoise113 %>%
  filter(handvCat %in% c("a", "i")) %>%
  count(URN, handvCat)

vowelNoiseRaw113 <- ggplot(count_df,
                        aes(x = factor(URN), y = n, fill = handvCat)) +
  geom_col(position = "stack") +
  xlab("URN") +
  ylab("Count") +ggtitle("Raw Counts (1+1+3)")+labs(fill = "Type")+
  theme_bw()




vowelNoise113Mod1d.eff<-allEffects(vowelNoise113Mod1d)
vowelNoise113Mod1dURN.eff.df<-as.data.frame(vowelNoise113Mod1d.eff$URN)
vowelNoise113Mod1dDuration.eff.df<-as.data.frame(vowelNoise113Mod1d.eff$Duration)


vowelNoise113Mod1dURNGG<-ggplot(vowelNoise113Mod1dURN.eff.df,aes(x=URN, y=fit))+geom_point()+ geom_errorbar(aes(ymin=lower, ymax=upper), width=0.1)+xlab("URN")+ylim(0,1) +ylab("Proportion of i-type")+ theme_bw() +ggtitle("Coda Quality (1+1+3)")#+ facet_grid(~feature)

vowelNoise113Mod1dDurationGG<-ggplot(vowelNoise113Mod1dDuration.eff.df,aes(x=Duration, y=fit))+geom_line()+ geom_ribbon(aes(ymin=lower, ymax=upper), alpha=0.2)+xlab("Duration")+ylim(0,1) +ylab("Proportion of i-type")+ theme_bw() +ggtitle("Duration (1+1+3)")#+ facet_grid(~feature)

ggarrange(vowelNoiseRaw113,vowelNoise113Mod1dURNGG,vowelNoise113Mod1dDurationGG,nrow=1)


ggarrange(vowelNoiseRaw113,vowelNoise113Mod1dURNGG,vowelNoise113Mod1dDurationGG,nrow=1)



ggarrange(vowelNoiseRaw,vowelNoiseModHandvcatGG,vowelNoiseModDurationGG,
          vowelNoiseRaw113,vowelNoise113Mod1dURNGG,vowelNoise113Mod1dDurationGG,ncol=3,nrow=2,labels="auto")










