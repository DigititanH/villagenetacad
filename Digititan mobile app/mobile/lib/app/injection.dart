import '../../application/academy/get_academies.dart';
import '../../application/academy/register_academy_interest.dart';
import '../../application/academy/register_academy_organisation.dart';
import '../../application/auth/register_with_email.dart';
import '../../application/auth/sign_in_with_email.dart';
import '../../application/auth/sign_in_with_google.dart';
import '../../application/auth/verify_email_otp.dart';
import '../../application/store/get_my_orders.dart';
import '../../application/store/get_products.dart';
import '../../application/store/place_order.dart';
import '../../application/training/get_programmes.dart';
import '../../application/training/get_training_offers.dart';
import '../../application/training/register_training_interest.dart';
import '../../domain/repositories/academy_repository.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/email_sender.dart';
import '../../domain/repositories/reseller_repository.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/repositories/training_repository.dart';
import '../../infrastructure/dummy/dummy_academy_repository.dart';
import '../../infrastructure/dummy/dummy_admin_repository.dart';
import '../../infrastructure/dummy/dummy_auth_repository.dart';
import '../../infrastructure/dummy/dummy_reseller_repository.dart';
import '../../infrastructure/dummy/dummy_store_repository.dart';
import '../../infrastructure/dummy/dummy_training_repository.dart';
import '../../infrastructure/email/console_email_sender.dart';

class AppContainer {
  late final AuthRepository authRepository;
  late final EmailSender emailSender;
  late final TrainingRepository trainingRepository;
  late final AcademyRepository academyRepository;
  late final StoreRepository storeRepository;
  late final ResellerRepository resellerRepository;
  late final AdminRepository adminRepository;

  late final SignInWithEmail signInWithEmail;
  late final RegisterWithEmail registerWithEmail;
  late final VerifyEmailOtp verifyEmailOtp;
  late final SignInWithGoogle signInWithGoogle;

  late final GetTrainingOffers getTrainingOffers;
  late final GetProgrammes getProgrammes;
  late final RegisterTrainingInterest registerTrainingInterest;

  late final GetAcademies getAcademies;
  late final RegisterAcademyInterest registerAcademyInterest;
  late final RegisterAcademyOrganisation registerAcademyOrganisation;

  late final GetProducts getProducts;
  late final PlaceOrder placeOrder;
  late final GetMyOrders getMyOrders;

  AppContainer() {
    authRepository = DummyAuthRepository();
    emailSender = ConsoleEmailSender();
    trainingRepository = DummyTrainingRepository();
    academyRepository = DummyAcademyRepository();
    storeRepository = DummyStoreRepository();
    resellerRepository = DummyResellerRepository();
    adminRepository = DummyAdminRepository();

    signInWithEmail = SignInWithEmail(authRepository);
    registerWithEmail = RegisterWithEmail(authRepository, emailSender);
    verifyEmailOtp = VerifyEmailOtp(authRepository);
    signInWithGoogle = SignInWithGoogle(authRepository);

    getTrainingOffers = GetTrainingOffers(trainingRepository);
    getProgrammes = GetProgrammes(trainingRepository);
    registerTrainingInterest = RegisterTrainingInterest(trainingRepository);

    getAcademies = GetAcademies(academyRepository);
    registerAcademyInterest = RegisterAcademyInterest(academyRepository);
    registerAcademyOrganisation = RegisterAcademyOrganisation(academyRepository);

    getProducts = GetProducts(storeRepository);
    placeOrder = PlaceOrder(storeRepository);
    getMyOrders = GetMyOrders(storeRepository);
  }
}
